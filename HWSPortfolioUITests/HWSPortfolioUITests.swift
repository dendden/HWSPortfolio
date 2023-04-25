//
//  HWSPortfolioUITests.swift
//  HWSPortfolioUITests
//
//  Created by Денис Трясунов on 25.04.2023.
//

import XCTest

final class HWSPortfolioUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {

        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    /*func testExample() throws {

        XCTAssertEqual(
            app.toolbarButtons.count, 2,
            "Content View toolbar must have 2 buttons: create and filter."
        )
    }*/

    /*func testCreateButtonAddsTag() {
        // navigate back to Sidebar
        app.buttons["Назад"].tap()
        XCTAssertEqual(
            app.tables.cells.count, 0,
            "There must be 2 smart filters in list initially."
        )
        // add new tag
        app.buttons["Додати новий тег"].tap()
        XCTAssertEqual(
            app.tables.cells.count, 1,
            "There must be 2 smart filters + 1 row with new tag."
        )
    }*/

    /*func testEditingIssueUpdatesCorrectly() {

        // add new issue and navigate to its editing screen
        app.buttons["Додати новий негаразд"].tap()

        // activate issue title text field
        app.textFields["New Issue"].tap()
        // edit issue title
        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        // navigate back to Content View
        app.buttons["Всі негаразди"].tap()

        // assert button (list row) with new name exists
        XCTAssertTrue(
            app.buttons["New Issue 2"].exists,
            "Name of edited new issue must be visible in the list."
        )
    }*/

    func testAddingTags() {
        // navigate back to Sidebar
        app.buttons["Назад"].tap()

        // add new tag
        app.buttons["Додати новий тег"].tap()

        // assert button (list row) with new tag exists
        XCTAssertTrue(
            app.buttons["New tag"].exists,
            "Name of new tag must be visible in the list."
        )
    }

    func testAllAwardsShowLockedAlert() {
        // navigate back to Sidebar
        app.buttons["Назад"].tap()
        // open Awards sheet
        app.buttons["Показати нагороди"].tap()

        // iterate over each award, tapping it
        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            award.tap()

            XCTAssertTrue(
                app.alerts["(locked)"].exists,
                "There must be an alert with (locked) in its title."
            )
            app.buttons["OK"].tap()
        }
    }
}
