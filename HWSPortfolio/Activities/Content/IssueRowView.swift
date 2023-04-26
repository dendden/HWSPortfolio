//
//  IssueRowView.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import SwiftUI

/// A SwiftUI View for presenting a single `Issue` row within
/// the list of issues of ``ContentView``.
///
/// The row acts as `NavigationLink` to ``IssueView`` and contains following elements:
/// + an "exclamation mark" SFSymbol image for issues with high priority
/// (for other priority levels this image is hidden with `opacity(0)`);
/// + a `VStack` of issue title and list of tags assigned to the issue;
/// + a `VStack` of issue creation date and "CLOSED" text for completed issues.
struct IssueRowView: View {

    @EnvironmentObject var dataController: DataController
    /// The issue to be displayed in this row.
    @ObservedObject var issue: Issue

    var body: some View {

        NavigationLink(value: issue) {

            HStack {

                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(issue.priority == 2 ? 1 : 0)

                VStack(alignment: .leading) {
                    Text(issue.issueTitle)
                        .font(.headline)
                        .lineLimit(1)

                    Text(issue.issueTagNames.formatted())
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(issue.issueCreationDate.formatted(date: .numeric, time: .omitted))
                        .font(.subheadline)

                    if issue.completed {
                        Text("Closed")
                            .font(.body.smallCaps())
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}

struct IssueRowView_Previews: PreviewProvider {
    static var previews: some View {
        IssueRowView(issue: .example)
    }
}
