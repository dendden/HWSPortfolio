//
//  String-Localized.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 21.04.2023.
//

import Foundation

extension String {

    /// Substitutes current string with its localized version by calling
    /// `NSLocalizedString` initializer on string's `self`.
    /// - Parameter comment: Optional localization comment. Defaults
    /// to empty string.
    /// - Returns: A localized version of the current `String`.
    func localized(comment: String = "") -> String {
        NSLocalizedString(self, comment: comment)
    }
}
