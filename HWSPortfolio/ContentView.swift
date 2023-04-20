//
//  ContentView.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 18.04.2023.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        List(selection: $dataController.selectedIssue) {
            ForEach(dataController.getIssuesForSelectedFilter()) { issue in
                IssueRowView(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle(navTitle)
        .searchable(text: $dataController.filterText, tokens: $dataController.filterTokens, suggestedTokens: .constant(dataController.suggestedFilterTokens), prompt: "Filter issues or type # to add tags") { tag in
            TagLabelView(tagName: tag.tagName)
        }
        .toolbar {
            Menu {
                Button(dataController.filterEnabled ? "Turn Off Filter" : "Turn On Filter") {
                    dataController.filterEnabled.toggle()
                }
                
                Divider()
                
                Menu("Sort By") {
                    Picker("Sort By", selection: $dataController.sortType) {
                        Text("Date Created").tag(SortType.dateCreated)
                        Text("Date Modified").tag(SortType.dateModified)
                    }
                    
                    Divider()
                    
                    Picker("Sorting Order", selection: $dataController.sortNewestFirst) {
                        Text("Newest First").tag(true)
                        Text("Oldest First").tag(false)
                    }
                }
                                    
                Picker("Status", selection: $dataController.filterByStatus) {
                    Text("All").tag(IssueStatus.all)
                    Text("Open").tag(IssueStatus.open)
                    Text("Closed").tag(IssueStatus.closed)
                }
                .disabled(!dataController.filterEnabled)
                                
                Picker("Priority", selection: $dataController.filterPriority) {
                    Text("All").tag(-1)
                    Text("Low").tag(0)
                    Text("Medium").tag(1)
                    Text("High").tag(2)
                }
                .disabled(!dataController.filterEnabled)
                
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    .symbolVariant(dataController.filterEnabled ? .fill : .none)
            }
        }
    }
    
    var navTitle: String {
        let filter = dataController.selectedFilter ?? .allIssues
        
        if let tag = filter.tag {
            return "#\(tag.tagName)"
        } else {
            return filter.name
        }
    }
    
    func delete(atOffsets offsets: IndexSet) {
        
        let issues = dataController.getIssuesForSelectedFilter()
        
        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataController.preview)
    }
}
