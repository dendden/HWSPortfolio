//
//  IssueSummaryView.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 22.04.2023.
//

import SwiftUI

struct IssueSummaryView: View {

    @ObservedObject var issue: Issue

    var body: some View {

        VStack(alignment: .leading) {

            TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                .font(.title)

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
