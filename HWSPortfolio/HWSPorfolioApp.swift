//
//  HWSPorfolioApp.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 18.04.2023.
//

import SwiftUI

@main
struct HWSPorfolioApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            
            NavigationSplitView {
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
            .onChange(of: scenePhase) { newPhase in
                if newPhase != .active {
                    dataController.save()
                }
            }
        }
    }
}
