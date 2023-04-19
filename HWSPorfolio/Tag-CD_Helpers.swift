//
//  Tag-CD_Helpers.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import Foundation

extension Tag {
    
    var tagID: UUID {
        self.id ?? UUID()
    }
    
    var tagName: String {
        self.name ?? ""
    }
    
    var tagAllIssues: [Issue] {
        self.issues?.allObjects as? [Issue] ?? []
    }
    
    var tagActiveIssues: [Issue] {
        let result = self.issues?.allObjects as? [Issue] ?? []
        return result.filter { !$0.completed }
    }
    
    static var example: Tag {
        
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let tag = Tag(context: viewContext)
        tag.id = UUID()
        tag.name = "Example Tag"
        
        return tag
    }
}

extension Tag: Comparable {
    
    public static func <(lhs: Tag, rhs: Tag) -> Bool {
        
        let left = lhs.tagName.localizedLowercase
        let right = rhs.tagName.localizedLowercase
        
        if left != right {
            return left < right
        } else {
            return lhs.tagID.uuidString < rhs.tagID.uuidString
        }
    }
}
