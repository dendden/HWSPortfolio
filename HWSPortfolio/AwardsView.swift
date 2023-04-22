//
//  AwardsView.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 20.04.2023.
//

import SwiftUI

struct AwardsView: View {
    
    @EnvironmentObject var dataController: DataController
    
    // will only be used when an award is selected, ok to fill in dummy data instead of optional
    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false
    
    let gridItemSide: CGFloat = 100
    
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
    
    var awardTitle: LocalizedStringKey {
        if dataController.hasEarned(selectedAward) {
            return "Unlocked: \(selectedAward.name)"
        } else {
            return "\(selectedAward.name) (locked)"
        }
    }
    
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
