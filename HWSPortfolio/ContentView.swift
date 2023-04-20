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
//            Text(tag.tagName)
            TagLabelView(tagName: tag.tagName)
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
