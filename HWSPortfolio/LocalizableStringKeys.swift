//
//  LocalizableStringKeys.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 22.04.2023.
//

import SwiftUI

enum StringKeys: LocalizedStringKey {
    case SHOW_AWARDS
    case ADD_NEW_TAG
    case SMART_FILTERS
    
    var localized: LocalizedStringKey {
        self.rawValue
    }
    
    // optionally can use static constants:
    static let smartFilters: LocalizedStringKey = "SMART_FILTERS"
}

// option to use within Text init():
extension Text {
    init(_ localizedString: StringKeys) {
        self.init(localizedString.rawValue)
    }
}
