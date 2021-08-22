//
//  Marvel_AppTests.swift
//  Marvel AppTests
//
//  Created by Fizza on 8/20/21.
//

import XCTest
@testable import Marvel_App

class Marvel_AppTests: XCTestCase {

    var sut:ViewController!
    
    
    func testValidID()
    {
        // Test app with valid comic ID
        
        // Set control (expected results after API call is processed)
        let controlTitle = "Marvel Knights Spider-Man (2004) #14"
        let controlDescription = "The Daily Bugle's got a new star reporter. Ethan Edwards is his name! Peter may get the pic, but not before Ethan's got the scoop. And if that weren't enough, there may be even more to Ethan than meets the eye...\n"
        let controlImageURL = "https://i.annihil.us/u/prod/marvel/i/mg/1/04/57ae48e7dcea9/portrait_xlarge.jpg"
        let controlAttributionURL = "https://marvel.com/comics/issue/2000/marvel_knights_spider-man_2004_14?utm_campaign=apiRef&utm_source=32b416300c15b326ac119c7fe07c0fa3\r\rData provided by Marvel.\n© 2014 Marvel"
        
        // Load view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(identifier: "ViewController")
        sut.loadViewIfNeeded()
        
        // Set expectation so program will wait for this to be fulfilled before moving on to test variables so program has enough time to make API request, recieve data, and process data
        let promise = XCTKVOExpectation(keyPath: "text", object: sut.titleLabel ?? "", expectedValue: "Marvel Knights Spider-Man (2004) #14")
        
        // Make API request with valid comic ID
        let input = "2000"
        sut.makeAPICall(input)
        
        // Wait for expectation to be fulfilled
        XCTWaiter().wait(for: [promise], timeout: 5)
        
        // Compare comic title, comic description, and URL of comic image that was processed from API with the control (expected results)
        XCTAssertEqual(self.sut.currentComic.title, controlTitle)
        XCTAssertEqual(self.sut.myComicDescription, controlDescription)
        XCTAssertEqual(self.sut.myImageURL, controlImageURL)
        XCTAssertEqual(self.sut.myAttributionURL, controlAttributionURL)
    }
    
    
    func testNoDescription()
    {
        // Test app with valid comic ID that has no description
        
        // Set control (expected results after API call is processed)
        let controlTitle = "Miles Morales: Spider-Man Annual (2021) #1"
        let controlDescription = "Description not available for this comic"
        let controlImageURL = "https://i.annihil.us/u/prod/marvel/i/mg/f/20/60e5e1d1b5fde/portrait_xlarge.jpg"
        let controlAttributionURL = "https://marvel.com/comics/issue/90386/miles_morales_spider-man_annual_2021_1?utm_campaign=apiRef&utm_source=32b416300c15b326ac119c7fe07c0fa3\r\rData provided by Marvel.\n© 2014 Marvel"
        
        // Load view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(identifier: "ViewController")
        sut.loadViewIfNeeded()
        
        // Set expectation so program will wait for this to be fulfilled before moving on to test variables so program has enough time to make API request, recieve data, and process data
        let promise = XCTKVOExpectation(keyPath: "text", object: sut.titleLabel ?? "", expectedValue: "Miles Morales: Spider-Man Annual (2021) #1")
        
        // Make API request with valid comic ID
        let input = "90386"
        sut.makeAPICall(input)
        
        // Wait for expectation to be fulfilled
        XCTWaiter().wait(for: [promise], timeout: 5)
        
        // Compare comic title, comic description, and URL of comic image that was processed from API with the control (expected results)
        XCTAssertEqual(self.sut.currentComic.title, controlTitle)
        XCTAssertEqual(self.sut.myComicDescription, controlDescription)
        XCTAssertEqual(self.sut.myImageURL, controlImageURL)
        XCTAssertEqual(self.sut.myAttributionURL, controlAttributionURL)
    }
    
    
    func testInvalidID()
    {
        // Test app with invalid comic ID
        
        // Set control (expected results after API call is processed
        let controlTitle = ""
        let controlDescription = ""
        let controlImageURL = ""
        let controlAttributionURL = ""
        
        // Load view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(identifier: "ViewController")
        sut.loadViewIfNeeded()
                
        let e = expectation(description: "finish API call")
        
        // Make API request with invalid comic ID
        let input = "123456789"
        let url = URL(string: "https://apple.com")!
        
        let dataTask = URLSession.shared.dataTask(with: url)
        {_,_,_ in
            self.sut.makeAPICall(input)
            e.fulfill()
        }
        
        // Wait for expectation to be fulfilled
        XCTWaiter().wait(for: [e], timeout: 5)
        
        // Compare comic title, comic description, and URL of comic image that was processed from API with the control (expected results)
        XCTAssertEqual(self.sut.currentComic.title, controlTitle)
        XCTAssertEqual(self.sut.myComicDescription, controlDescription)
        XCTAssertEqual(self.sut.myImageURL ?? "", controlImageURL)
        XCTAssertEqual(self.sut.myAttributionURL, controlAttributionURL)
    }
    
    
    func testNoID()
    {
        // Test app with no comic ID
        
        // Set control (expected results after API call is processed
        let controlTitle = ""
        let controlDescription = ""
        let controlImageURL = ""
        let controlAttributionURL = ""
        
        // Load view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(identifier: "ViewController")
        sut.loadViewIfNeeded()
                
        // Make API request with invalid comic ID
        self.sut.searchButtonTapped((Any).self)
                
        // Compare comic title, comic description, and URL of comic image that was processed from API with the control (expected results)
        XCTAssertEqual(self.sut.currentComic.title, controlTitle)
        XCTAssertEqual(self.sut.myComicDescription, controlDescription)
        XCTAssertEqual(self.sut.myImageURL ?? "", controlImageURL)
        XCTAssertEqual(self.sut.myAttributionURL, controlAttributionURL)
    }
    
    
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
}
