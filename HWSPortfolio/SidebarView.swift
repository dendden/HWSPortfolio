//
//  SidebarView.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import SwiftUI

struct SidebarView: View {
    
    @EnvironmentObject var dataController: DataController
    
    let smartFilters: [Filter] = [.allIssues, .recentIssues]
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    
    @State private var tagToRename: Tag?
    @State private var isRenamingTag = false
    @State private var editedTagName = ""
    
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
        }
    }
    
    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
            }
            Section("Tags") {
                ForEach(tagFilters) { filter in
                    NavigationLink(value: filter) {
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
                .onDelete(perform: delete)
            }
        }
        .toolbar {
            
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
            Button("OK", action: completeRaname)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $editedTagName)
        }
    }
    
    func delete(atOffsets offsets: IndexSet) {
        for offset in offsets {
            let item = tags[offset]
            dataController.delete(item)
        }
    }
    
    func rename(filter: Filter) {
        self.tagToRename = filter.tag
        self.editedTagName = filter.name
        self.isRenamingTag = true
    }
    
    func completeRaname() {
        if !self.editedTagName.isEmpty {
            self.tagToRename?.name = self.editedTagName.trimmingCharacters(in: .whitespaces)
            dataController.save()
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
            .environmentObject(DataController.preview)
    }
}
