//
//  DetailView.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import SwiftUI

// a temporary solution to silence error about `.inline` title display mode
// not available on MacOS.
extension View {
    /// Modifies the view with an `.inline` navigation bar title display
    /// mode on `iOS` devices. Leaves the view unmodified on other operating
    /// systems.
    /// - Returns: A view with nav bar title display mode
    /// modifications applied on `iOS` devices.
    func multiPlatformInlineNavigationBarTitle() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

struct DetailView: View {

    @EnvironmentObject var dataController: DataController

    var body: some View {
        VStack {
            if let issue = dataController.selectedIssue {
                IssueView(issue: issue)
            } else {
                NoIssueView()
            }
        }
        .navigationTitle("Details")
        .multiPlatformInlineNavigationBarTitle()
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
