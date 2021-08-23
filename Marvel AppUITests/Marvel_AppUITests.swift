//
//  Marvel_AppUITests.swift
//  Marvel AppUITests
//
//  Created by Fizza on 8/20/21.
//

import XCTest

class Marvel_AppUITests: XCTestCase {
    
    var app:XCUIApplication!
    
    
    override func setUp() {
        
        super.setUp()
        
        // If failure encountered, do not continue
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
    }
    
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testValidID() {
        
        //Test app with valid comic ID
        
        // Launch app
        app.launch()
        
        //Tap textfield and enter valid comic ID
        app.textFields.element.tap()
        sleep(1)
        app.textFields.element.typeText("41778")
        
        // Tap "search" button, wait for display to load, scroll down, scroll up
        app.buttons["searchButton"].tap()
        sleep(3)
        app.swipeUp()
        app.swipeDown()
        
    }
    
    
    func testInvalidID()
    {
        // Test app with invalid comic ID input
        
        // Launch app
        app.launch()
        
        //Tap textfield and enter invalid comic ID
        app.textFields.element.tap()
        sleep(1)
        app.textFields.element.typeText("123456789")
        
        // Tap "search" button, wait for display to load, dismiss the alert that appears
        app.buttons["searchButton"].tap()
        sleep(2)
        app.tap()
    }
    
    
    func testNoID()
    {
        // Test app with no comic ID input
        
        // Launch app
        app.launch()
        
        // Tap "search" button, wait for display to load, dismiss the alert that appears
        app.buttons["searchButton"].tap()
        sleep(2)
        app.tap()
    }
}
