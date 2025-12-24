//
//  CatFinderSwipeUITests.swift
//  CatFinderSwipeUITests
//
//  Created by David on 22/12/2025.
//

import XCTest

final class CatFinderSwipeUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testSmallDragTriggersFallingAnimationOverlay() throws {
        let app = XCUIApplication()
        app.launch()

        let currentCard = app.otherElements["SwipeDeck.CurrentCard"]

        // Wait for the first card to appear.
        XCTAssertTrue(currentCard.waitForExistence(timeout: 10))

        // Perform a small drag (below the swipe decision threshold) to trigger the fall/drift animation.
        let start = currentCard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let end = currentCard.coordinate(withNormalizedOffset: CGVector(dx: 0.65, dy: 0.65))
        start.press(forDuration: 0.05, thenDragTo: end)

        // The falling path uses an overlay for the outgoing animation.
        let overlay = app.otherElements["SwipeDeck.SwipingOverlay"]
        XCTAssertTrue(overlay.waitForExistence(timeout: 2.0))
    }
}
