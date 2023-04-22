//
//  TagsCloudView.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import SwiftUI

struct TagsCloudView: View {

    let tags: [Tag]

    var body: some View {
        TagLabelView(tagName: "#Test35")
    }
}

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
