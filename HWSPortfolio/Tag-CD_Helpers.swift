//
//  Tag-CD_Helpers.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import Foundation

extension Tag {

    /// A non-optional representation of `Core Data`'s `Tag.id` parameter.
    ///
    /// If parameter's value is `nil`, this variable returns a new instance
    /// of `UUID()`.
    var tagID: UUID {
        self.id ?? UUID()
    }

    /// A non-optional representation of `Core Data`'s `Tag.name` parameter.
    ///
    /// If parameter's value is `nil`, this variable returns an empty `String`.
    var tagName: String {
        self.name ?? ""
    }

    /// An unwrapped value of `Core Data`'s `Tag.issues` relationship
    /// casted to a non-optional array of `Issues`.
    ///
    /// If casting returns `nil`, this variable returns an empty array.
    var tagAllIssues: [Issue] {
        self.issues?.allObjects as? [Issue] ?? []
    }

    /// An unwrapped value of `Core Data`'s `Tag.issues` relationship
    /// casted to a non-optional array of `Issues` and **filtered** to
    /// include only issues with completion status of "*Open*".
    ///
    /// If casting returns `nil`, this variable returns an empty array.
    var tagActiveIssues: [Issue] {
        let result = self.issues?.allObjects as? [Issue] ?? []
        return result.filter { !$0.completed }
    }

    /// A temporary in-memory instance of `Tag` entity for testing
    /// and previewing purposes.
    ///
    /// This example `Tag` is instantiated with `Tag.name` set to
    /// "*Example Tag*".
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

    public static func < (lhs: Tag, rhs: Tag) -> Bool {

        let left = lhs.tagName.localizedLowercase
        let right = rhs.tagName.localizedLowercase

        if left != right {
            return left < right
        } else {
            return lhs.tagID.uuidString < rhs.tagID.uuidString
        }
    }
}
