//
//  IssueReminderPickerView.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 28.04.2023.
//

import SwiftUI

/// A section of ``IssueView`` responsible for Issue notification settings.
struct IssueReminderPickerView: View {

    @EnvironmentObject var dataController: DataController

    @ObservedObject var issue: Issue

    @State private var pickerIsShowing: Bool
    @State private var pickedTime: Date

    init(_ issue: Issue) {
        self.issue = issue

        self._pickerIsShowing = State(wrappedValue: issue.reminderTime != nil)
        self._pickedTime = State(wrappedValue: issue.reminderTime ?? .now)
    }

    var body: some View {

        Toggle(isOn: $pickerIsShowing.animation()) {
            Text("\("Set Reminder".localized()) \(Image(systemName: "bell.badge"))")
        }
        .onChange(of: pickerIsShowing) { isOn in
            if !isOn {
                issue.reminderTime = nil
                pickedTime = .now
            } else {
                issue.reminderTime = pickedTime
            }
        }

        if pickerIsShowing {
            DatePicker("Select Time", selection: $pickedTime, displayedComponents: .hourAndMinute)
                .onChange(of: pickedTime) { newValue in
                    if pickerIsShowing {
                        issue.reminderTime = newValue
                    }
                }
        }
    }
}

struct IssueReminderPickerView_Previews: PreviewProvider {
    static var previews: some View {
        IssueReminderPickerView(Issue.example)
    }
}
