//
//  DataController.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 18.04.2023.
//

import CoreData

enum SortType: String {
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

enum IssueStatus {
    case all, open, closed
}

class DataController: ObservableObject {
    
    let container: NSPersistentCloudKitContainer
    
    @Published var selectedFilter: Filter? = Filter.allIssues
    @Published var selectedIssue: Issue?
    
    @Published var filterText = ""
    @Published var filterTokens = [Tag]()
    
    @Published var filterEnabled = false
    @Published var filterPriority = -1
    @Published var filterByStatus = IssueStatus.all
    @Published var sortType = SortType.dateCreated
    @Published var sortNewestFirst = true
    
    private var saveTask: Task<Void, Error>?
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
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
    
    init(inMemory: Bool = false) {
        self.container = NSPersistentCloudKitContainer(name: "Main")
        
        if inMemory {
            // write this file to nowhere (never save it)
            self.container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        // Make announcement when remote changes happen
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator, queue: .main, using: remoteStoreChanged)
        
        self.container.loadPersistentStores { storeDescription, error in
            if let error {
                fatalError("Fatal error loading persistent stores: \(error.localizedDescription)")
            }
        }
    }
    
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    
    func createSampleData() {
        let viewContext = self.container.viewContext
        
        for i in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag\(i)"
            
            for j in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(i)_\(j)"
                issue.content = "Description of issue goes here..."
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                
                tag.addToIssues(issue)
            }
        }
        
        try? viewContext.save()
    }
    
    func save() {
        if self.container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    func queueSave() {
        saveTask?.cancel()
        
        // explicitly force the Task to main thread, otherwise it might run on background
        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        self.container.viewContext.delete(object)
        self.save()
    }
    
    private func delete(fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.container.viewContext])
        }
    }
    
    func deleteAll() {
        let tagRequest: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        self.delete(fetchRequest: tagRequest)
        
        let issueRequest: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        self.delete(fetchRequest: issueRequest)
        
        self.save()
    }
    
    func getMissingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(issue.issueTags)
        
        return difference.sorted()
    }
    
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
        
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
        if !trimmedFilterText.isEmpty {
            // [c] stands for case-insensitive for a predicate (which is sensitive by default)
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)
            let combinedFilterPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
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
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]
        
        let allIssues = (try? self.container.viewContext.fetch(request)) ?? []
        
        // Option with filtering all fetched issues:
        /*if !trimmedFilterText.isEmpty {
            allIssues = allIssues.filter { $0.issueTitle.localizedCaseInsensitiveContains(trimmedFilterText) || $0.issueContent.localizedCaseInsensitiveContains(trimmedFilterText) }
        }*/
        
        return allIssues.sorted()
    }
    
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
    
    func addNewTag() {
        let newTag = Tag(context: container.viewContext)
        newTag.id = UUID()
        newTag.name = "New tag"
        
        save()
    }
    
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
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
}
