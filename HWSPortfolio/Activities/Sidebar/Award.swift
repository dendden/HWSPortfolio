//
//  Award.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 20.04.2023.
//

import Foundation

/// A SwiftUI representation of a single `Award` from the list of awards
/// in `Award.json` bundle file.
struct Award: Decodable, Identifiable {

    var name: String
    /// An explanation of achievement for which this award is given.
    var description: String
    /// A SwiftUI color from `Colors.xcassets` file, which decorates this
    /// award in UI when earned.
    var color: String
    /// A characteristic of a data element or user action to which this
    /// award is related.
    ///
    /// E.g. **"issue"**, **"tag"**, **"premium unlock"** etc.
    var criterion: String
    /// A number of data elements or user actions described in ``criterion``
    /// that are required for this award to be earned.
    var value: Int
    /// A name of SFSymbol or other icon visually depicting this award in UI.
    var image: String

    var id: String { self.name }

    /// A static array of all awards decoded from `Awards.json` bundle file.
    static let allAwards = Bundle.main.decode("Awards.json", as: [Award].self)
    /// A static demo `Award` used for SwiftUI Previews and other
    /// testing purposes.
    ///
    /// Contains first award in ``allAwards`` by default.
    static let example = allAwards[0]
}
