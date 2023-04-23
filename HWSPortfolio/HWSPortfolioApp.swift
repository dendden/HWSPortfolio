//
//  HWSPortfolioApp.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 18.04.2023.
//

import SwiftUI

@main
struct HWSPortfolioApp: App {

    /// An environment variable to observes changes in app life cycle.
    ///
    /// Here `scenePhase` is used to save data whenever the app becomes
    /// inactive.
    @Environment(\.scenePhase) var scenePhase

    /// A global variable for managing interactions between Core Data
    /// and UI.
    ///
    /// This variable is initiated once and gets passed as `EnvironmentObject`
    /// to all Views that require Core Data interaction.
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
