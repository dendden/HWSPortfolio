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
        
        self.container.loadPersistentStores { storeDescription, error in
            if let error {
                fatalError("Fatal error loading persistent stores: \(error.localizedDescription)")
            }
        }
    }
    
    func createSampleData() {
        let viewContext = self.container.viewContext
        
        for i in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(i)"
            
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
}
