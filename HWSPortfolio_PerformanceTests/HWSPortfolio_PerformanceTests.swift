//
//  HWSPortfolio_PerformanceTests.swift
//  HWSPortfolio_PerformanceTests
//
//  Created by Денис Трясунов on 25.04.2023.
//

import CoreData
import XCTest
@testable import HWSPortfolio

class BaseTestCase: XCTestCase {

    var dataController: DataController!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        context = dataController.container.viewContext
    }

}
