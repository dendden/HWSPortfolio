//
//  DevelopmentTests.swift
//  HWSPortfolioTests
//
//  Created by Денис Трясунов on 24.04.2023.
//

import CoreData
import XCTest
@testable import HWSPortfolio

final class DevelopmentTests: BaseTestCase {

    func testSampleDataCreation() {
        dataController.createSampleData()

        XCTAssertEqual(
            dataController.count(for: Tag.fetchRequest()),
            5,
            "Sample data must contain 5 tags."
        )

        XCTAssertEqual(
            dataController.count(for: Issue.fetchRequest()),
            50,
            "Sample data must contain 50 issues."
        )
    }

    func testExampleIssueHasHighPriority() {
        for _ in 0..<100 {
            let issue = Issue.example

            XCTAssertEqual(
                issue.priority,
                2,
                "Example issue must have high priority (2)."
            )
        }
    }

    func testExampleIssueIsOpen() {
        for _ in 0..<100 {
            let issue = Issue.example

            XCTAssertFalse(
                issue.completed,
                "Example issue must have high priority (2)."
            )
        }
    }

}
