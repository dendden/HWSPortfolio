//
//  IssueSummaryView.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 22.04.2023.
//

import SwiftUI

/// The top section of ``IssueView`` containing text field with issue title,
/// its modification date and completion status.
struct IssueSummaryView: View {

    @ObservedObject var issue: Issue
    /// A toggle describing keyboard focus state on the issue title
    /// text field.
    ///
    /// This variable is passed from parent ``IssueView`` and attached
    /// to the issue title text field.
    @FocusState var issueTitleIsFocused: Bool

    var body: some View {

        VStack(alignment: .leading) {

            TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                .font(.title)
                .focused($issueTitleIsFocused)

            Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                .foregroundStyle(.secondary)

            HStack {
                Text("**Status:** \(issue.issueStatus.uppercased())")
                if issue.completed {
                    Image(systemName: "checkmark.circle.fill")
                        .imageScale(.small)
                }
            }
            .foregroundStyle(.secondary)
        }
    }
}
