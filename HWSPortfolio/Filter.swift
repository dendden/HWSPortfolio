//
//  Filter.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import Foundation

struct Filter: Identifiable, Hashable {
    
    static let day: Double = 86_400
    
    var id: UUID
    var name: String
    var icon: String
    var minModificationDate = Date.distantPast
    var tag: Tag?
    
    static var allIssues = Filter(id: UUID(), name: "All Issues".localized(), icon: "tray")
    static var recentIssues = Filter(id: UUID(), name: "Recent Issues".localized(), icon: "clock", minModificationDate: .now.addingTimeInterval(Filter.day * -7))
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
