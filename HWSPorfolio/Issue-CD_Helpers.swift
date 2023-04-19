//
//  Issue-CD_Helpers.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import Foundation

extension Issue {
    
    var issueTitle: String {
        get { self.title ?? "" }
        set { self.title = newValue }
    }
    
    var issueContent: String {
        get { self.content ?? "" }
        set { self.content = newValue }
    }
    
    var issueCreationDate: Date {
        self.creationDate ?? .now
    }
    
    var issueModificationDate: Date {
        self.modificationDate ?? .now
    }
    
    var isueTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }
    
    static var example: Issue {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let issue = Issue(context: viewContext)
        issue.title = "Example Issue"
        issue.content = "This is the content of an example issue."
        issue.priority = 2
        issue.creationDate = .now
        
        return issue
    }
}

extension Issue: Comparable {
    
    public static func <(lhs: Issue, rhs: Issue) -> Bool {
        
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase
        
        if left != right {
            return lhs.issueTitle < rhs.issueTitle
        } else {
            return lhs.issueCreationDate < rhs.issueCreationDate
        }
    }
}
