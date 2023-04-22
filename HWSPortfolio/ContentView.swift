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
        .navigationTitle(dataController.selectedContentNavigationTitle)
        .searchable(text: $dataController.filterText, tokens: $dataController.filterTokens, suggestedTokens: .constant(dataController.suggestedFilterTokens), prompt: "Filter issues or type # to add tags") { tag in
            TagLabelView(tagName: tag.tagName)
        }
        .toolbar {
            
            Button(action: dataController.addNewIssue) {
                Label("Add new issue", systemImage: "square.and.pencil")
            }
            
            FilterMenuView()
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
