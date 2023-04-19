//
//  ContentView.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 18.04.2023.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var dataController: DataController
    
    var issues: [Issue] {
        let filter = dataController.selectedFilter ?? .allIssues
        var allIssues: [Issue]
        
        if let tag = filter.tag {
            allIssues = tag.tagAllIssues
        } else {
            let request = Issue.fetchRequest()
            request.predicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            allIssues = (try? dataController.container.viewContext.fetch(request)) ?? []
        }
        
        return allIssues.sorted()
    }
    
    var navTitle: String {
        let filter = dataController.selectedFilter ?? .allIssues
        
        if let tag = filter.tag {
            return "#\(tag.tagName)"
        } else {
            return filter.name
        }
    }
    
    var body: some View {
        List(selection: $dataController.selectedIssue) {
            ForEach(issues) { issue in
                IssueRowView(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle(navTitle)
    }
    
    func delete(atOffsets offsets: IndexSet) {
        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
