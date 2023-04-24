//
//  AwardTests.swift
//  HWSPortfolioTests
//
//  Created by Денис Трясунов on 24.04.2023.
//

import CoreData
import XCTest
@testable import HWSPortfolio

final class AwardTests: BaseTestCase {

    let awards = Award.allAwards

    // check if award's name is award's id (no changes were made to id property)
    func testAwardIDMatchesName() {
        for award in awards {
            XCTAssertEqual(
                award.id,
                award.name,
                "Award ID must always match its name."
            )
        }
    }

    // check that new user does not have any earned awards
    func testNoAwardsForNewUser() {
        for award in awards {
            XCTAssertFalse(
                dataController.hasEarned(award),
                "New users must not have any earned awards."
            )
        }
    }

    func testAddingIssuesForAwards() {
        let awardedValues = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in awardedValues.enumerated() {
            for _ in 0..<value {
                _ = Issue(context: context)
            }

            let matchingAwards = awards.filter { award in
                award.criterion == "issues" && dataController.hasEarned(award)
            }

            XCTAssertEqual(
                matchingAwards.count,
                count + 1,
                "Adding \(value) issues must unlock \(count+1) awards."
            )

            dataController.deleteAll()
        }
    }

    func testAddingTagsForAwards() {
        let awardedValues = [1, 10, 50]

        for (count, value) in awardedValues.enumerated() {
            for _ in 0..<value {
                _ = Tag(context: context)
            }

            let matchingAwards = awards.filter { award in
                award.criterion == "tags" && dataController.hasEarned(award)
            }

            XCTAssertEqual(
                matchingAwards.count,
                count + 1,
                "Adding \(value) tags must unlock \(count+1) awards."
            )

            dataController.deleteAll()
        }
    }

    func testClosingIssuesForAwards() {
        // Given
        let awardedValues = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in awardedValues.enumerated() {
            // When
            for _ in 0..<value {
                let issue = Issue(context: context)
                issue.completed = true
            }

            let matchingAwards = awards.filter { award in
                award.criterion == "closed" && dataController.hasEarned(award)
            }

            // Then
            XCTAssertEqual(
                matchingAwards.count,
                count + 1,
                "Closing \(value) issues must unlock \(count+1) awards."
            )

            dataController.deleteAll()
        }
    }
}
