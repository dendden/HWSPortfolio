//
//  IssueView.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import SwiftUI

struct IssueView: View {
    
    @EnvironmentObject var dataController: DataController
    
    @ObservedObject var issue: Issue
    
    var body: some View {
        
        Form {
            
            Section {
                
                VStack(alignment: .leading) {
                    
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)
                    
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Text("**Status:** \(issue.issueStatus.uppercased())")
                        if issue.completed {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.small)
                        }
                    }
                    .foregroundStyle(.secondary)
                }
                
                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
            }
            
            Section {
                VStack(alignment: .leading) {
                    
                    Text("Tags:")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    Menu {
                        // show selected tags first:
                        ForEach(issue.issueTags) { tag in
                            Button {
                                issue.removeFromTags(tag)
                            } label: {
                                Label(tag.tagName, systemImage: "checkmark")
                            }
                        }
                        
                        // then show unselected tags:
                        let otherTags = dataController.getMissingTags(from: issue)
                        
                        if !otherTags.isEmpty {
                            Divider()
                            
                            Section("Add Tags") {
                                ForEach(otherTags) { tag in
                                    Button(tag.tagName) {
                                        issue.addToTags(tag)
                                    }
                                }
                            }
                        }
                    } label: {
                        Text(issue.issueTagNames.formatted())
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(nil, value: issue.issueTagNames)
                    }
                }
            }
            
            Section {
                
                VStack(alignment: .leading) {
                    
                    Text("Basic Information:")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    TextField("Description", text: $issue.issueContent, prompt: Text("Enter the issue description here"), axis: .vertical)
                }
            }
        }
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
    }
}

struct IssueView_Previews: PreviewProvider {
    static var previews: some View {
        IssueView(issue: .example)
            .environmentObject(DataController.preview)
    }
}
