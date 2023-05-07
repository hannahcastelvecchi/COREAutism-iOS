//
//  COREAutism_iOS_WatchKit_Extension_Watch_AppUITestsLaunchTests.swift
//  COREAutism-iOS WatchKit Extension Watch AppUITests
//
//  Created by Hannah Castelvecchi on 5/1/23.
//

import XCTest

final class COREAutism_iOS_WatchKit_Extension_Watch_AppUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
