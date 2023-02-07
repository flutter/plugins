//
//  URLLauncherUITests.swift
//  RunnerUITests
//
//  Created by Andres Gutierrez on 2/7/23.
//  Copyright © 2023 The Flutter Authors. All rights reserved.
//

import Foundation
import XCTest

class URLLauncherUITests: XCTestCase {
    override func setUp() {
        self.continueAfterFailure = false
        
        XCUIApplication().launch()
    }
    
    func testLaunch() {
        let app = XCUIApplication()
        
        let buttonNames = ["Launch in app", "Launch in app(JavaScript ON)", "Launch in app(DOM storage ON)", "Launch a universal link in a native app, fallback to Safari.(Youtube)"
        ]
        
        for buttonName in buttonNames {
            let button = app.buttons[buttonName]
            XCTAssertTrue(button.waitForExistence(timeout: 30.0))
            XCTAssertEqual(app.webViews.count, 0)
            
            button.tap()
            let webView = app.webViews.firstMatch
            XCTAssertTrue(webView.waitForExistence(timeout: 30.0))
            XCTAssertTrue(app.buttons["ForwardButton"].waitForExistence(timeout: 30.0))
            XCTAssertTrue(app.buttons["Share"].exists)
            XCTAssertTrue(app.buttons["OpenInSafariButton"].exists)
            
            app.buttons["Done"].tap()
        }
    }
}
