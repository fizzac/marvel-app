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
        
        // Set control (expected results after API call is processed
        let actualComic = Comic.init(titleParam: "Marvel Knights Spider-Man (2004) #14", descriptionParam: "The Daily Bugle's got a new star reporter. Ethan Edwards is his name! Peter may get the pic, but not before Ethan's got the scoop. And if that weren't enough, there may be even more to Ethan than meets the eye...\r\rData provided by Marvel.\n© 2014 Marvel", thumbnailParam: ["path":"http://i.annihil.us/u/prod/marvel/i/mg/1/04/57ae48e7dcea9", "extension":"jpg"])
        
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
        XCTAssertEqual(self.sut.currentComic.title, actualComic.title)
        XCTAssertEqual(self.sut.currentComic.description, actualComic.description)
        XCTAssertEqual(self.sut.currentComic.thumbnail["path"], actualComic.thumbnail["path"])
    }
    
    func testInvalidID()
    {
        // Test app with invalid comic ID
        
        // Set control (expected results after API call is processed
        let actualComic = Comic.init(titleParam: "", descriptionParam: "", thumbnailParam:["":""])
        
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
        XCTAssertEqual(self.sut.currentComic.title, actualComic.title)
        XCTAssertEqual(self.sut.currentComic.description, actualComic.description)
        XCTAssertEqual(self.sut.currentComic.thumbnail["path"], actualComic.thumbnail["path"])
    }
    
    func testNoID()
    {
        // Test app with no comic ID
        
        // Set control (expected results after API call is processed
        let actualComic = Comic.init(titleParam: "", descriptionParam: "", thumbnailParam:["":""])
        
        // Load view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(identifier: "ViewController")
        sut.loadViewIfNeeded()
                
        // Make API request with invalid comic ID
        self.sut.searchButtonTapped((Any).self)
                
        // Compare comic title, comic description, and URL of comic image that was processed from API with the control (expected results)
        XCTAssertEqual(self.sut.currentComic.title, actualComic.title)
        XCTAssertEqual(self.sut.currentComic.description, actualComic.description)
        XCTAssertEqual(self.sut.currentComic.thumbnail["path"], actualComic.thumbnail["path"])
    }
    
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
}
