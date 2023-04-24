//
//  HWSPortfolioTests.swift
//  HWSPortfolioTests
//
//  Created by Денис Трясунов on 24.04.2023.
//

import CoreData
import XCTest
@testable import HWSPortfolio

class BaseTestCase: XCTestCase {

    var dataController: DataController!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        print(">>> loading BaseTestCase...")
        dataController = DataController(inMemory: true)
        context = dataController.container.viewContext
    }

}
