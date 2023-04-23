//
//  Issue-CD_Helpers.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import Foundation

extension Issue {

    /// A non-optional representation of `Core Data`'s `Issue.title` parameter.
    ///
    /// If parameter's value is `nil`, this variable returns an empty `String`.
    var issueTitle: String {
        get { self.title ?? "" }
        set { self.title = newValue }
    }

    /// A non-optional representation of `Core Data`'s `Issue.content` parameter.
    ///
    /// If parameter's value is `nil`, this variable returns an empty `String`.
    var issueContent: String {
        get { self.content ?? "" }
        set { self.content = newValue }
    }

    /// A non-optional representation of `Core Data`'s `Issue.creationDate` parameter.
    ///
    /// If parameter's value is `nil`, this variable returns current `Date`.
    var issueCreationDate: Date {
        self.creationDate ?? .now
    }

    /// A non-optional representation of `Core Data`'s `Issue.modificationDate` parameter.
    ///
    /// If parameter's value is `nil`, this variable returns current `Date`.
    var issueModificationDate: Date {
        self.modificationDate ?? .now
    }

    /// An unwrapped value of `Core Data`'s `Issue.tags` relationship
    /// casted to a non-optional array of `Tags`.
    ///
    /// If casting returns `nil`, this variable returns an empty array.
    /// Array of tags is **sorted** prior to returning value.
    var issueTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }

    /// An array of all tag names mapped from `issueTags` variable, each
    /// preceded by `#` symbol.
    ///
    /// + if `tags` parameter of `Issue` entity returns as `nil`,
    /// this variable returns an array with single localized string
    /// "*No tags*"
    /// + if `tags` parameter of `Issue` entity contains 0 values,
    /// this variable returns an array with single localized string
    /// "*No tags*"
    var issueTagNames: [String] {
        guard let tags else { return ["No tags".localized()] }

        if tags.count == 0 { return ["No tags".localized()] }

        return issueTags.map { tag in
            "#\(tag.tagName)"
        }
    }

    /// A `String` representation of `Issue` entity's `completed`
    /// parameter.
    ///
    /// + for completed issues, this variable returns localized
    /// string "*Closed*"
    /// + for non-completed issues, this variable returns localized
    /// string "*Open*"
    var issueStatus: String {
        self.completed ? "Closed".localized() : "Open".localized()
    }

    /// A temporary in-memory instance of `Issue` entity for testing
    /// and previewing purposes.
    ///
    /// This example `Issue` is instantiated with following parameters:
    /// + **title** set to "*Example Issue*"
    /// + **content** set to "*This is the content of an example issue.*"
    /// + **priority** set to 2 (*medium*)
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

    public static func < (lhs: Issue, rhs: Issue) -> Bool {

        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase

        if left != right {
            return lhs.issueTitle < rhs.issueTitle
        } else {
            return lhs.issueCreationDate < rhs.issueCreationDate
        }
    }
}
