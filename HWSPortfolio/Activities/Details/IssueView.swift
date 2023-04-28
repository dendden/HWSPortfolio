//
//  IssueView.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import SwiftUI

/// A SwiftUI view laying out details about the given issue and controls
/// to edit issue name and description, choose new priority and manage
/// tags attached to the issue.
struct IssueView: View {

    @EnvironmentObject var dataController: DataController

    /// A toggle describing keyboard focus state on the issue title
    /// text field.
    @FocusState var issueTitleIsFocused: Bool
    /// A toggle describing keyboard focus state on the issue content
    /// text field.
    @FocusState var issueContentIsFocused: Bool

    /// Issue to be displayed and edited.
    @ObservedObject var issue: Issue

    /// A toggle triggering display of Notifications error alert.
    @State private var showingNotificationError = false

    var body: some View {

        Form {

            Section {

                IssueSummaryView(issue: issue, issueTitleIsFocused: _issueTitleIsFocused)

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
                IssueReminderPickerView(issue)
                    .alert("Error", isPresented: $showingNotificationError) {
                        Button("Cancel", role: .cancel) {}
                        Button("Settings", action: showSystemSettings)
                    } message: {
                        Text("Check notification settings for HWSPortfolio.")
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
                    .focused($issueContentIsFocused)
                }
            }

            Section {

                Button("Close issue") {
                    dataController.closeIssue(issue)
                }
            }
        }
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            handleEmptyIssueTitleIfNeeded()
            dataController.queueSave(issue) { success in
                if !success {
                    showingNotificationError = true
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done".localized()) {
                    // dismiss any active keyboard
                    issueTitleIsFocused = false
                    issueContentIsFocused = false
                }
            }
        }
    }

    /// Checks for empty string upon keyboard dismiss after editing
    /// issue title text field. If title was left empty - default name
    /// of "**Issue**" is assigned to issue.
    private func handleEmptyIssueTitleIfNeeded() {
        // If user left Text Field empty after dismissing keyboard -
        // - return default name for the Issue
        if !issueTitleIsFocused {
            if issue.issueTitle.trimmingCharacters(in: .whitespaces) == "" {
                issue.issueTitle = "Issue"
            }
        }
    }

    /// Opens Notifications settings for `HWSPortfolio` as an action from Notifications
    /// error alert.
    private func showSystemSettings() {
        guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else { return
        }

        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }

}

struct IssueView_Previews: PreviewProvider {
    static var previews: some View {
        IssueView(issue: .example)
            .environmentObject(DataController.preview)
    }
}
