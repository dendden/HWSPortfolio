//
//  AssetTest.swift
//  HWSPortfolioTests
//
//  Created by Денис Трясунов on 24.04.2023.
//

import XCTest
@testable import HWSPortfolio

final class AssetTest: XCTestCase {

    func testJSONLoadsCorrectly() {
        XCTAssertFalse(
            Award.allAwards.isEmpty,
            "Failed to load awards from JSON"
        )
    }

    func testColorsExist() {
        let awardColors = Award.allAwards.map { $0.color }
        for color in awardColors {
            XCTAssertNotNil(
                UIColor(named: color),
                "Failed to load color '\(color)' from asset catalog"
            )
        }
    }

}
