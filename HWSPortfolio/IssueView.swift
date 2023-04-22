//
//  IssueView.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import SwiftUI

struct IssueView: View {

    @EnvironmentObject var dataController: DataController

    @ObservedObject var issue: Issue

    var body: some View {

        Form {

            Section {

                IssueSummaryView(issue: issue)

                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
            }

            Section {
                VStack(alignment: .leading) {

                    Text("Tags:")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    IssueTagsMenuView(issue: issue)
                }
            }

            Section {

                VStack(alignment: .leading) {

                    Text("Basic Information:")
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    TextField(
                        "Description",
                        text: $issue.issueContent,
                        prompt: Text("Enter the issue description here"), axis: .vertical
                    )
                }
            }
        }
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            if issue.issueTitle == "" {
                issue.issueTitle = "Issue"
            }
            dataController.queueSave()
        }
    }
}

struct IssueView_Previews: PreviewProvider {
    static var previews: some View {
        IssueView(issue: .example)
            .environmentObject(DataController.preview)
    }
}
