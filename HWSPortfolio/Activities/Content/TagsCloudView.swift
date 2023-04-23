//
//  TagsCloudView.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import SwiftUI

/// A perspective collection of ``TagLabelView`` views to display
/// within an ``IssueRowView`` or as a list of issue tags to label
/// ``IssueTagsMenuView``.
struct TagsCloudView: View {

    let tags: [Tag]

    var body: some View {
        TagLabelView(tagName: "#Test35")
    }
}

/// A SwiftUI View representing a single tag in a capsule shape.
///
/// This View is used to represent `filterTokens` for each tag when user
/// interacts with ``ContentView`` search field starting their prompt
/// with a `#` symbol.
struct TagLabelView: View {

    let tagName: String

    var body: some View {
        Text(tagName)
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 5)
            .padding(.horizontal)
            .background(Capsule().fill(.gray))
    }
}

struct TagLabelView_Previews: PreviewProvider {
    static var previews: some View {
        TagsCloudView(tags: [.example, .example, .example, .example, .example, .example, .example, .example, .example])
    }
}
