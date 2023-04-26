//
//  ContentView.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 18.04.2023.
//

import CoreSpotlight
import SwiftUI

/// A SwiftUI view displaying the list of issues from the filter
/// selected in ``SidebarView``.
struct ContentView: View {

    /// An environment object responsible for interacting with Core Data,
    /// such as fetching, filtering and sorting entities, as well as
    /// evaluating entity values, saving and deleting them.
    @EnvironmentObject var dataController: DataController

    var body: some View {
        List(selection: $dataController.selectedIssue) {
            ForEach(dataController.getIssuesForSelectedFilter()) { issue in
                IssueRowView(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle(dataController.selectedContentNavigationTitle)
        .searchable(
            text: $dataController.filterText,
            tokens: $dataController.filterTokens,
            suggestedTokens: .constant(dataController.suggestedFilterTokens),
            prompt: "Filter issues or type # to add tags"
        ) { tag in
            TagLabelView(tagName: tag.tagName)
        }
        .toolbar {

            Button(action: dataController.addNewIssue) {
                Label("Add new issue", systemImage: "square.and.pencil")
            }

            FilterMenuView()
        }
        .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightIssue)
    }

    /// Calls ``dataController``'s ``DataController/delete(_:)`` method on
    /// each issue specified in `offsets` parameter.
    /// - Parameter offsets: A set of indexes in the `List`, at which
    /// issues must be deleted.
    func delete(atOffsets offsets: IndexSet) {

        let issues = dataController.getIssuesForSelectedFilter()

        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }

    func loadSpotlightIssue(_ userActivity: NSUserActivity) {
        if let uniqueID = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            dataController.selectIssueFromSpotlight(issueID: uniqueID)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataController.preview)
    }
}
