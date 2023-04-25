//
//  AwardsView.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 20.04.2023.
//

import SwiftUI

/// The view representing all awards available to user in the app
/// as a grid of buttons with icons.
///
/// Earned awards are presented in color, while locked awards are in
/// gray color. This view is presented as a sheet from ``SidebarView``.
struct AwardsView: View {

    /// An environment object responsible for interacting with Core Data,
    /// such as fetching, filtering and sorting entities, as well as
    /// evaluating entity values, saving and deleting them.
    @EnvironmentObject var dataController: DataController

    // will only be used when an award is selected, ok to fill in dummy data instead of optional
    /// A variable that contains `Award` selected by user.
    ///
    /// Used here for displaying appropriate alert with award description
    /// and earned status when tapped.
    @State private var selectedAward = Award.example
    /// A toggle that controls showing/dismissing alert with details about
    /// selected award.
    @State private var showingAwardDetails = false

    /// A dimension of single award `gridItem` square side, used here
    /// for representing award button in UI.
    let gridItemSide: CGFloat = 100

    /// An array of grid item columns with adaptive layout and size within
    /// the ``gridItemSide`` value.
    ///
    /// This view uses a single `GridItem`.
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: gridItemSide, maximum: gridItemSide))]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards, content: makeAwardButton)
                }
            }
            .navigationTitle("Awards")
        }
        .alert(awardTitle, isPresented: $showingAwardDetails) {
        } message: {
            Text(selectedAward.description)
        }
    }

    /// The title for selected award alert, composed of award's name
    /// and **locked**/**unlocked** comment depending on award's
    /// `earned` status.
    var awardTitle: LocalizedStringKey {
        if dataController.hasEarned(selectedAward) {
            return "Unlocked: \(selectedAward.name)"
        } else {
            #if DEBUG
            return "(locked)"
            #else
            return "\(selectedAward.name) (locked)"
            #endif
        }
    }

    /// Creates a button for a single award in the grid.
    ///
    /// Button color depends on award's `earned` status.
    /// - Parameter award: An `Award`, which will be selected by this button.
    /// - Returns: A `Button` that selects given award and toggles display
    /// of alert with given award's description.
    private func makeAwardButton(for award: Award) -> some View {
        Button {
            selectedAward = award
            showingAwardDetails = true
        } label: {
            Image(systemName: award.image)
                .resizable()
                .scaledToFit()
                .padding()
                .frame(width: gridItemSide, height: gridItemSide)
                .foregroundColor(dataController.hasEarned(award) ? Color(award.color) : .secondary.opacity(0.5))
        }
    }
}

struct AwardsView_Previews: PreviewProvider {
    static var previews: some View {
        AwardsView()
    }
}
