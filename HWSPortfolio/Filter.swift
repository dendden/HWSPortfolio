//
//  Filter.swift
//  HWSPorfolio
//
//  Created by Денис Трясунов on 19.04.2023.
//

import Foundation

/// A generalized struct that provides filtering `Issues` both by static 'Smart Filter' properties
/// ('All Issues' and 'Recent Issues') and by `Tags` assigned to `Issues`.
struct Filter: Identifiable, Hashable {

    static let day: Double = 86_400

    var id: UUID
    /// Name of the filter that is displayed in UI.
    var name: String
    /// SF Symbol or other icon for the filter to display in UI.
    var icon: String
    /// Minimum modification date of an `Issue` for it to be included in filter results.
    var minModificationDate = Date.distantPast
    /// Optional `Tag` that `Issue` must contain for it to be included in filter results.
    var tag: Tag?

    /// Static `Filter` value with no limitations to issues it contains, aka all issues in database.
    static var allIssues = Filter(id: UUID(), name: "All Issues", icon: "tray")
    /// Static `Filter` value which includes only issues modified not earlier than 7 days before current time.
    static var recentIssues = Filter(
        id: UUID(), name: "Recent Issues",
        icon: "clock",
        minModificationDate: .now.addingTimeInterval(Filter.day * -7)
    )

    // Custom Hashable conformance limiting hash combination to compute only
    // `id` property of the Filter.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
