//
//  SidebarViewModel.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 25.04.2023.
//

import CoreData
import Foundation

extension SidebarView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

        var dataController: DataController

        //        @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
        /// A bridge between `ViewModel` and `Core Data` that monitors
        /// for changes in the list of tag objects in database.
        private let tagsController: NSFetchedResultsController<Tag>
        /// All tag objects stored in database and fetched by `tagsController`.
        @Published var tags = [Tag]()

        /// A variable containing a `Tag` list item, on which context menu with
        /// "Rename" action was called.
        var tagToRename: Tag?
        /// A toggle that controls showing/dismissing alert with a text field to
        /// edit the `Tag` name.
        @Published var isRenamingTag = false
        /// A temporary storage for the new name of `Tag` edited by user.
        ///
        /// If not empty, this temporary name gets written to the edited
        /// `Tag` permanently by ``completeRename()`` function when
        /// user submits editing result.
        var editedTagName = ""

        /// An array of ``Filter`` objects mapped from ``tags`` fetch request.
        var tagFilters: [Filter] {
            tags.map { tag in
                Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
            }
        }

        init(dataController: DataController) {
            self.dataController = dataController

            let request = Tag.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
            tagsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil, cacheName: nil
            )
            super.init()
            tagsController.delegate = self

            do {
                try tagsController.performFetch()
                self.tags = tagsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch tags within Sidebar VM.")
            }
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

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newObjects = controller.fetchedObjects as? [Tag] {
                self.tags = newObjects
            }
        }
    }
}
