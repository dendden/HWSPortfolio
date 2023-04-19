//
//  DataController.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 18.04.2023.
//

import CoreData

class DataController: ObservableObject {
    
    let container: NSPersistentCloudKitContainer
    
    @Published var selectedFilter: Filter? = Filter.allIssues
    @Published var selectedIssue: Issue?
    
    private var saveTask: Task<Void, Error>?
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
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
}
