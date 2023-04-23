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

    /// An environment object responsible for interacting with Core Data,
    /// such as fetching, filtering and sorting entities, as well as
    /// evaluating entity values, saving and deleting them.
    @EnvironmentObject var dataController: DataController

    /// An array of static smart filters.
    ///
    /// Contains 2 ``Filter`` values: ``Filter/allIssues`` and ``Filter/recentIssues``.
    let smartFilters: [Filter] = [.allIssues, .recentIssues]

    /// An `fetchResult` of all tags stored in database.
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>

    /// A variable containing a `Tag` list item, on which context menu with
    /// "Rename" action was called.
    @State private var tagToRename: Tag?
    /// A toggle that controls showing/dismissing alert with a text field to
    /// edit the `Tag` name.
    @State private var isRenamingTag = false
    /// A temporary storage for the new name of `Tag` edited by user.
    ///
    /// If not empty, this temporary name gets written to the edited
    /// `Tag` permanently by ``completeRename()`` function when
    /// user submits editing result.
    @State private var editedTagName = ""

    /// A toggle that controls showing/dismissing the sheet with ``AwardsView``.
    ///
    /// This toggle is set to true by "**Awards**" toolbar button.
    @State private var showingAwards = false

    /// An array of ``Filter`` objects mapped from ``tags`` fetch request.
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
        }
    }

    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section(StringKeys.smartFilters.localized) {
                ForEach(smartFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
            }
            Section("Tags") {
                ForEach(tagFilters) { filter in
                    NavigationLink(value: filter) {
                        makeTagFilterLinkLabel(filter: filter)
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .toolbar {

            Button {
                showingAwards.toggle()
            } label: {
                Label(StringKeys.showAwards.localized, systemImage: "rosette")
            }

            Button(action: dataController.addNewTag) {
                Label("Add new tag", systemImage: "tag")
            }

            #if DEBUG
            Button {
                dataController.deleteAll()
                dataController.createSampleData()
            } label: {
                Label("ADD SAMPLES", systemImage: "flame")
            }
            #endif
        }
        .alert("Rename Tag", isPresented: $isRenamingTag) {
            Button("OK", action: completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $editedTagName)
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)
    }

    /// Calls ``dataController``'s ``DataController/delete(_:)`` method on each tag
    /// specified in `offsets` parameter.
    /// - Parameter offsets: A set of indexes in the `List`, at which
    /// tags must be deleted.
    func delete(atOffsets offsets: IndexSet) {
        for offset in offsets {
            let item = tags[offset]
            dataController.delete(item)
        }
    }

    /// Assigns tag to be renamed into dedicated @State variable,
    /// sets `editedTagName` @State variable to given tag's current name
    /// and sets `isRenamingTag` toggle to `true`, displaying the
    /// rename alert.
    /// - Parameter filter: A tag to be renamed.
    func rename(filter: Filter) {
        self.tagToRename = filter.tag
        self.editedTagName = filter.name
        self.isRenamingTag = true
    }

    /// Calls ``dataController``'s ``DataController/save()`` method to
    /// write changes from tag rename to storage.
    ///
    /// If rename text field is empty when user taps "OK" button -
    /// this method does nothing, so previous tag name is not overwritten.
    func completeRename() {
        if !self.editedTagName.isEmpty {
            self.tagToRename?.name = self.editedTagName.trimmingCharacters(in: .whitespaces)
            dataController.save()
        }
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
                    rename(filter: filter)
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
            }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
            .environmentObject(DataController.preview)
    }
}
