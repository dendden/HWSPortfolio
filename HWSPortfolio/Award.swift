//
//  Award.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 20.04.2023.
//

import Foundation

struct Award: Decodable, Identifiable {

    var name: String
    var description: String
    var color: String
    var criterion: String
    var value: Int
    var image: String

    var id: String { self.name }

    static let allAwards = Bundle.main.decode("Awards.json", as: [Award].self)
    static let example = allAwards[0]
}
