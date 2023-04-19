//
//  TagLabelView.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import SwiftUI

struct TagLabelView: View {
    
    let tag: Tag
    
    var body: some View {
        Text(tag.tagName)
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 5)
            .padding(.horizontal)
            .background(Capsule().fill(.gray))
    }
}

struct TagLabelView_Previews: PreviewProvider {
    static var previews: some View {
        TagLabelView(tag: .example)
    }
}
