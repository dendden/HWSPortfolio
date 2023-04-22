//
//  String-Localized.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 21.04.2023.
//

import Foundation

extension String {

    func localized(comment: String = "") -> String {
        NSLocalizedString(self, comment: comment)
    }
}
