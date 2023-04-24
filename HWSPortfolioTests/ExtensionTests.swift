//
//  ExtensionTests.swift
//  HWSPortfolioTests
//
//  Created by Денис Трясунов on 24.04.2023.
//

import XCTest
@testable import HWSPortfolio

final class ExtensionTests: XCTestCase {

    // Fixture json files are not in Main.bundle - so we create
    // a local bundle for current test file.
    let bundle = Bundle(for: ExtensionTests.self)

    func testBundleDecodingAwards() {
        let awards = Bundle.main.decode("Awards.json", as: [Award].self)

        XCTAssertFalse(
            awards.isEmpty,
            "Awards.json must decode to a non-empty array."
        )
    }

    func testDecodingString() {

        let decodedString = bundle.decode("DecodableString.json", as: String.self)

        XCTAssertEqual(
            decodedString,
            "Wollt ihr das Bett in Flamen sehen?",
            "Decoded string must be: 'Wollt ihr das Bett in Flamen sehen?'"
        )
    }

    func testDecodingDictionary() {

        // Given
        let expectedDict = [
            "zero": 0,
            "one": 1,
            "two": 2,
            "three": 3
        ]

        // When
        let decodedDict = bundle.decode("DecodableDictionary.json", as: [String: Int].self)

        // Then
        XCTAssertEqual(
            decodedDict,
            expectedDict,
            "Decoded dictionary must match expected dictionary."
        )
    }

}
