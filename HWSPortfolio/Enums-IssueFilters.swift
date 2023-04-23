//
//  Enums-IssueFilters.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 23.04.2023.
//

import Foundation

/// An enum containing available issue date attributes to filter by: either creation date or modification date.
enum SortType: String {
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

/// An enum containing available issue completion statuses to filter by.
enum IssueStatus {
    /// List all issues - both completed and not completed.
    case all
    /// List only issues with `completed` attribute set to `false`.
    case open
    /// List only issues with `completed` attribute set to `false`.
    case closed
}
