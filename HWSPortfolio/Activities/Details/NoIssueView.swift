//
//  NoIssueView.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import SwiftUI

/// A SwiftUI View to represent ``DetailView`` when no issue is selected.
/// This view contains a button to call `DataController`'s
/// ``DataController/addNewIssue()`` method.
struct NoIssueView: View {

    @EnvironmentObject var dataController: DataController

    var body: some View {
        VStack {
            Text("No Issue Selected")
                .font(.title)
                .foregroundStyle(.secondary)

            Button("New Issue", action: dataController.addNewIssue)
                .buttonStyle(.borderedProminent)
                .tint(.secondary)
        }
    }
}

struct NoIssueView_Previews: PreviewProvider {
    static var previews: some View {
        NoIssueView()
            .environmentObject(DataController.preview)
    }
}
