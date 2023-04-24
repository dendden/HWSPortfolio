//
//  TagTests.swift
//  HWSPortfolioTests
//
//  Created by Денис Трясунов on 24.04.2023.
//

import CoreData
import XCTest
@testable import HWSPortfolio

final class TagTests: BaseTestCase {

    func testCreatingTagsAndIssues() {
        let targetCount = 10

        for _ in 0..<targetCount {
            let tag = Tag(context: context)

            for _ in 0..<targetCount {
                let issue = Issue(context: context)
                tag.addToIssues(issue)
            }
        }

        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), targetCount)
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), targetCount * 10)
    }

    func testDeletingTags() throws {
        dataController.createSampleData()

        dataController.delete(fetchRequest: Tag.fetchRequest())

        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 0)
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 50)
    }

    func testDeletingIssues() throws {
        dataController.createSampleData()

        dataController.delete(fetchRequest: Issue.fetchRequest())

        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 5)
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 0)
    }

}
