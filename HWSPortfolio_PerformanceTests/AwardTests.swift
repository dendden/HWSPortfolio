//
//  AwardTests.swift
//  HWSPortfolio_PerformanceTests
//
//  Created by Денис Трясунов on 25.04.2023.
//

import XCTest
@testable import HWSPortfolio

final class AwardTests: BaseTestCase {

    func testAwardCalculationPerformance() {

         /*
        dataController.createSampleData()
        let awards = Award.allAwards
        */

        // create a significant amount of test data:
        for _ in 1...100 {
            dataController.createSampleData()
        }

        // simulate significant number of awards to check:
        let awards = Array(repeating: Award.allAwards, count: 25).joined()

        // Verify that is fair in that it's run against current no. of awards
        XCTAssertEqual(
            awards.count,
            500,
            "This checks the number of awards is constant. Change if new awards were added."
        )

        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }

}
