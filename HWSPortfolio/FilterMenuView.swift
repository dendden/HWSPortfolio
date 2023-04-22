//
//  FilterMenuView.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 22.04.2023.
//

import SwiftUI

struct FilterMenuView: View {
    
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        
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

struct FilterMenuView_Previews: PreviewProvider {
    static var previews: some View {
        FilterMenuView()
    }
}
