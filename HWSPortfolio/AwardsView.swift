//
//  AwardsView.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 20.04.2023.
//

import SwiftUI

struct AwardsView: View {
    
    let gridItemSide: CGFloat = 100
    
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: gridItemSide, maximum: gridItemSide))]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            // action later..
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: gridItemSide, height: gridItemSide)
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                    }
                }
            }
            .navigationTitle("Awards")
        }
    }
}

struct AwardsView_Previews: PreviewProvider {
    static var previews: some View {
        AwardsView()
    }
}
