//
//  DataController.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 18.04.2023.
//

import CoreData
import SwiftUI

// swiftlint:disable file_length

/// An environment singleton class responsible for handling interaction between UI and Core Data,
/// including saving, counting, fetching, sorting and deleting data.
/// This class also creates sample data for testing purposes.
class DataController: ObservableObject {

    /// The CloudKit container used for storing and retrieving data.
    let container: NSPersistentCloudKitContainer

    /// Optional current ``Filter`` value used for fetching related `Issues` from Core Data
    /// and displaying corresponding Navigation Title of the ``ContentView``.
    ///
    /// Defaults to 'All Issues'.
    @Published var selectedFilter: Filter? = Filter.allIssues
    /// Optional currently selected `Issue` that defines whether ``DetailView`` should display
    /// details ``IssueView`` for user-selected `Issue` or show ``NoIssueView`` if value is nil.
    @Published var selectedIssue: Issue?

    /// Contents of ``ContentView`` search field used for filtering displayed `Issues`.
    ///
    /// Initiates with an empty string.
    @Published var filterText = ""
    /// Array of `Tags` specified by user in ``ContentView``'s search field by preceding prompt
    /// with a '#' symbol to filter displayed issues by tags they contain.
    ///
    /// Initiates with an empty array.
    @Published var filterTokens = [Tag]()

    /// Toggle defining whether filter by issue priority or completion status is enabled in ``ContentView``.
    ///
    /// Initiates with `false` value.
    @Published var filterEnabled = false
    /// Priority value by which issues must be filtered.
    ///
    /// Initiates with '-1' for 'All Priorities'. Priority values are: 0 for 'Low', 1 for 'Medium', 2 for 'High'.
    @Published var filterPriority = -1
    /// Completion status ``IssueStatus`` by which issues must be filtered.
    ///
    /// Initiates with ``IssueStatus/all``. Priority values are: 0 for 'Low', 1 for 'Medium', 2 for 'High'.
    @Published var filterByStatus = IssueStatus.all
    /// Issue date attribute which should be used when sorting issues in a list.
    ///
    /// Initiates with ``SortType/dateCreated``.
    @Published var sortType = SortType.dateCreated
    /// A toggle which defines sorting order for issues in accordance with selected ``sortType``.
    ///
    /// Initiates with `true`.
    @Published var sortNewestFirst = true

    /// Task used by ``queueSave()`` method to perform `save()` operation on
    /// an `Issue` that is being edited by user.
    ///
    /// If editing continues within defined interval, this task gets cancelled and restarted.
    private var saveTask: Task<Void, Error>?

    /// Example ``DataController`` instance for use in SwiftUI Previews.
    ///
    /// Gets initiated in temporary storage ('inMemory') and filled with sample data.
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()

    /// A cached computed property that returns an instance of
    /// `managedObjectModel` loaded from `Bundle.main.momd` file.
    ///
    /// Using static model allows to avoid ambiguity when running tests.
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate Model file in Bundle.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load Model file from Bundle.")
        }

        return managedObjectModel
    }()

    /// Array of `Tags` that correspond to filter commands input by user in
    /// ``ContentView`` search field.
    ///
    /// Gets computed iff ``filterText`` starts with '#' symbol by executing a `Tag` fetch request
    /// with a predicate set to the contents of ``filterText``.
    var suggestedFilterTokens: [Tag] {
        guard filterText.starts(with: "#") else { return [] }

        // omit '#' from filtering
        let trimmedFilterText = String(filterText.dropFirst().trimmingCharacters(in: .whitespaces))
        let request = Tag.fetchRequest()

        if !trimmedFilterText.isEmpty {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }

        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }

    /// Initializes a `DataController`, either in memory (for testing purposes), or on permanent storage
    /// (for nominal app runs).
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Defines whether `DataController` should be initialized for testing
    /// in temporary memory or nominal app run in permanent memory.
    init(inMemory: Bool = false) {
        self.container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

        // Fore testing/previewing purposes - create a temporary in-memory database
        // by writing to '/dev/null' so that data is destroyed after the app exits.
        if inMemory {
            // write this file to nowhere (never save it)
            self.container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }

        // Merge priority for local persistent store
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        // Make announcement when remote changes happen
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged
        )

        self.container.loadPersistentStores { _, error in
            if let error {
                fatalError("Fatal error loading persistent stores: \(error.localizedDescription)")
            }

            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self.deleteAll()
                UIView.setAnimationsEnabled(false)
            }
            #endif
        }
    }

    /// Sends out `objectWillChange` message to all observers of ``DataController`` in response
    /// to receiving remote change notification.
    /// - Parameter notification: Intended to receive `.NSPersistentStoreRemoteChange`
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }

    /// Creates and saves to context sample data for testing and previewing purposes.
    ///
    /// This method creates 5 Tags titled '**Tag1**' through '**Tag5**'
    /// and 10 Issues for each Tag titled '**Issue 1_[tag_number]**'
    /// through '**Issue 10_[tag_number]**'.
    func createSampleData() {
        let viewContext = self.container.viewContext

        for tagCounter in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag\(tagCounter)"

            for issueCounter in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(tagCounter)_\(issueCounter)"
                issue.content = "Description of issue goes here..."
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)

                tag.addToIssues(issue)
            }
        }

        try? viewContext.save()
    }

    /// Attempts to save context data to permanent storage container iff context has changes.
    ///
    /// Silently ignores any errors sent by calling `save()` on NSManagedObjectContext,
    /// which is fine because Core Data attributes are optional.
    func save() {
        if self.container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }

    // Save changes to the Issue on-the-go with 3-second pauses as the user types in
    // deletes information regarding Issue properties
    /// Cancels current `saveTask` on @MainActor and starts new one with a 3 seconds sleep.
    ///
    /// This method is called by ``IssueView`` in response to changes published by `Issue` when user edits its content.
    func queueSave() {
        saveTask?.cancel()

        // explicitly force the Task to main thread, otherwise it might run on background
        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }

    func delete(_ object: NSManagedObject) {
        // notify observers to update their UI.
        objectWillChange.send()
        self.container.viewContext.delete(object)
        save()
    }

    /// Attempts to execute a `NSBatchDeleteRequest` on passed `fetchRequest`.
    ///
    /// If execution is successful, this method merges changes resulted from
    /// `NSBatchDeleteRequest` into `viewContext`.
    /// - Parameter fetchRequest: An `NSFetchRequest` for given `NSManagedObject`, results
    /// of which must be deleted from container.
    func delete(fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.container.viewContext])
        }
    }

    /// Deletes all `Tag` and `Issue` entities from `NSManagedObjectContext`
    /// and saves changes to container.
    ///
    /// This method is used alongside ``createSampleData()`` for testing and
    /// previewing purposes.
    func deleteAll() {
        let tagRequest: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        self.delete(fetchRequest: tagRequest)

        let issueRequest: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        self.delete(fetchRequest: issueRequest)

        save()
    }

    /// Fetches tags that are not attached to given `Issue` from `NSManagedObjectContext`.
    ///
    /// This method is used by `Issue` editing view to suggest available tags.
    /// - Parameter issue: An `Issue` entity, for which available tags must be fetched.
    /// - Returns: An array of `Tag` entities in `NSManagedObjectContext` that are not
    /// attached to the given `Issue`.
    func getMissingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(issue.issueTags)

        return difference.sorted()
    }

    /// Fetches issues from `NSManagedObjectContext` that pass the current
    /// ``selectedFilter`` and (when applicable) - contents of ``filterText``.
    ///
    /// This method checks for available filtering conditions to apply
    /// fetch predicates:
    /// 1. Predicates for ``selectedFilter`` defaulting to ``Filter/allIssues``
    /// when `nil`.
    /// 2. Predicates that comply with contents of ``filterText``.
    /// 3. Predicates that match with ``filterTokens`` (tags) selected by user.
    /// 4. If ``filterEnabled`` property is set to `true` - predicates that match
    /// ``filterPriority`` and ``filterByStatus`` properties.
    ///
    /// Finally, this method applies sort descriptors complying with
    /// ``sortNewestFirst`` property.
    /// - Returns: An array of issues that comply with all filtering parameters.
    func getIssuesForSelectedFilter() -> [Issue] {
        let filter = self.selectedFilter ?? .allIssues
        var predicates = [NSPredicate]()

        if let tag = filter.tag {
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }

        // create predicates for issues that are being searched in Search Field
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
        // no additional predicates needed for when search field is empty
        if !trimmedFilterText.isEmpty {
            // [c] stands for case-insensitive for a predicate (which is sensitive by default)
            // filter issues by search parameters matching either Issue's title OR its content
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)
            let combinedFilterPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [titlePredicate, contentPredicate]
            )
            predicates.append(combinedFilterPredicate)
        }

        if !filterTokens.isEmpty {
            // an option to filter issues containing ANY of selected tags
            let tokenPredicate = NSPredicate(format: "ANY tags in %@", filterTokens)
            predicates.append(tokenPredicate)
            // an option to filter only issues that contain ALL selected tags:
            /*for token in filterTokens {
                let tagPredicate = NSPredicate(format: "tags CONTAINS %@", token)
                predicates.append(tagPredicate)
            }*/
        }

        if filterEnabled {
            if filterPriority >= 0 {
                let priorityPredicate = NSPredicate(format: "priority = %d", filterPriority)
                predicates.append(priorityPredicate)
            }

            if filterByStatus != .all {
                let lookForClosed = filterByStatus == .closed
                let statusPredicate = NSPredicate(format: "completed = %@", NSNumber(value: lookForClosed))
                predicates.append(statusPredicate)
            }
        }

        let request = Issue.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: !sortNewestFirst)]

        let allIssues = (try? self.container.viewContext.fetch(request)) ?? []

        // Option with filtering all fetched issues:
        /*if !trimmedFilterText.isEmpty {
            allIssues = allIssues.filter { $0.issueTitle.localizedCaseInsensitiveContains(trimmedFilterText)
                ||
                $0.issueContent.localizedCaseInsensitiveContains(trimmedFilterText)
            }
        }*/

        return allIssues
    }

    /// Creates a new `Issue` entity and saves it to `NSManagedObjectContext`.
    ///
    /// Default values for newly created entities are:
    /// + "**New Issue**" for `title`
    /// + "**1 (medium)**" for `priority`
    ///
    /// If this method is called from a list of `Tag` issues - current `Tag`
    /// is added to the new `Issue`. Also, ``selectedIssue`` parameter is set
    /// to the new issue, so that ``IssueView`` is pushed onto navigation stack
    /// for editing.
    func addNewIssue() {
        let newIssue = Issue(context: container.viewContext)
        newIssue.title = "New Issue"
        newIssue.creationDate = .now
        newIssue.priority = 1

        // if issue is being added from a list of Tag issues - assign that tag to the new issue
        if let tag = selectedFilter?.tag {
            newIssue.addToTags(tag)
        }

        // navigate to new issue editing screen
        selectedIssue = newIssue

        save()
    }

    /// Marks given issue as completed and saves changes
    /// in persistent store.
    /// - Parameter issue: An issue to mark as closed.
    func closeIssue(_ issue: Issue) {
        issue.completed = true
        save()
    }

    /// Creates a new `Tag` entity and saves it to `NSManagedObjectContext`
    /// with a default name of "**New tag**".
    func addNewTag() {
        let newTag = Tag(context: container.viewContext)
        newTag.id = UUID()
        newTag.name = "New tag"

        save()
    }

    /// Calculates the number of entities returned by given `fetchRequest`.
    /// - Parameter fetchRequest: A request which result must be calculated.
    /// - Returns: The number of `NSManagedObject` entities returned from
    /// given `fetchRequest`.
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    /// Evaluates whether given award was earned by user by comparing `Award` value
    /// with the ``count(for:)`` entities that correspond to award criterion.
    /// - Parameter award: An `Award` that must be evaluated for `earned` status.
    /// - Returns: `true` if given award is evaluated as earned, `false` otherwise.
    func hasEarned(_ award: Award) -> Bool {
        switch award.criterion {

        case "issues":
            // return true if user added a certain amount of issues
            let request = Issue.fetchRequest()
            let awardCount = count(for: request)
            return awardCount >= award.value

        case "closed":
            // return true if user closed a certain amount of issues
            let request = Issue.fetchRequest()
            request.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: request)
            return awardCount >= award.value

        case "tags":
            // return true if user created a certain amount of tags
            let request = Tag.fetchRequest()
            let awardCount = count(for: request)
            return awardCount >= award.value

        default:
            // unknown award criterion - should never happen in prod!
//            fatalError("Unknown award criterion: \(award.criterion).")
            return false
        }
    }

    /// A localized navigation title for ``ContentView`` that corresponds
    /// to filter or tag name of ``selectedFilter``.
    var selectedContentNavigationTitle: LocalizedStringKey {
        let filter = selectedFilter ?? .allIssues

        if let tag = filter.tag {
            return "#\(tag.tagName)"
        } else {
            return LocalizedStringKey(filter.name)
        }
    }
}
