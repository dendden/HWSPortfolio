//
//  IssueTagsMenuView.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 22.04.2023.
//

import SwiftUI

/// A `Menu` for removing and adding available tags for the given issue.
///
/// Displays a list of attached tags on top, then a list of tags
/// available to select on bottom. `Menu` is labeled with a formatted
/// list of tags attached to the given issue (or text "No tags" if no
/// tags are attached).
struct IssueTagsMenuView: View {

    @EnvironmentObject var dataController: DataController

    let issue: Issue

    var body: some View {

        Menu {
            // show selected tags first:
            ForEach(issue.issueTags) { tag in
                Button {
                    issue.removeFromTags(tag)
                } label: {
                    Label(tag.tagName, systemImage: "checkmark")
                }
            }

            // then show unselected tags:
            let otherTags = dataController.getMissingTags(from: issue)

            if !otherTags.isEmpty {
                Divider()

                Section("Add Tags") {
                    ForEach(otherTags) { tag in
                        Button(tag.tagName) {
                            issue.addToTags(tag)
                        }
                    }
                }
            }
        } label: {
            Text(issue.issueTagNames.formatted())
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(nil, value: issue.issueTagNames)
        }
    }
}
