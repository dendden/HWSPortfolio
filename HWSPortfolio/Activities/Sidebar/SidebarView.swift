//
//  SidebarView.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import SwiftUI

/// The root navigation point of the app, displaying lists of
/// smart filters and tags by which all issues are grouped.
struct SidebarView: View {

    @StateObject var viewModel: ViewModel

    /// An array of static smart filters.
    ///
    /// Contains 2 ``Filter`` values: ``Filter/allIssues`` and ``Filter/recentIssues``.
    let smartFilters: [Filter] = [.allIssues, .recentIssues]

    /// A toggle that controls showing/dismissing the sheet with ``AwardsView``.
    ///
    /// This toggle is set to true by "**Awards**" toolbar button.
    @State private var showingAwards = false

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(selection: $viewModel.dataController.selectedFilter) {
            Section(StringKeys.smartFilters.localized) {
                ForEach(smartFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
            }
            Section("Tags") {
                ForEach(viewModel.tagFilters) { filter in
                    NavigationLink(value: filter) {
                        makeTagFilterLinkLabel(filter: filter)
                    }
                }
                .onDelete(perform: viewModel.delete)
            }
        }
        .toolbar {

            Button {
                showingAwards.toggle()
            } label: {
                Label(StringKeys.showAwards.localized, systemImage: "rosette")
            }

            Button(action: viewModel.dataController.addNewTag) {
                Label("Add new tag", systemImage: "tag")
            }

            #if DEBUG
            Button {
                viewModel.dataController.deleteAll()
                viewModel.dataController.createSampleData()
            } label: {
                Label("ADD SAMPLES", systemImage: "flame")
            }
            #endif
        }
        .alert("Rename Tag", isPresented: $viewModel.isRenamingTag) {
            Button("OK", action: viewModel.completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $viewModel.editedTagName)
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)
    }

    /// Creates a `Label` for a tag row in tags list.
    /// - Parameter filter: A tag for which list row label must be composed.
    /// - Returns: A `Label` with tag name and a badge showing number of open issues
    /// for the given tag.
    ///
    /// A context menu is attached to the label with an action for
    /// renaming the given tag.
    func makeTagFilterLinkLabel(filter: Filter) -> some View {
        Label(filter.name, systemImage: filter.icon)
            .badge(filter.tag?.tagActiveIssues.count ?? 0)
            .contextMenu {
                Button {
                    viewModel.rename(filter: filter)
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
            }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(dataController: DataController.preview)
    }
}
