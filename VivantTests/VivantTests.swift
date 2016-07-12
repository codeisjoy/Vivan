//
//  VivantTests.swift
//  VivantTests
//
//  Created by Emad A. on 12/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import XCTest
@testable import Vivant

class VivantTests: XCTestCase {
    
    var network: NetworkCenter?
    
    override func setUp() {
        super.setUp()
        network = NetworkCenter.defaultCenter
    }
    
    func testGettingPosts() {
        let expectation = expectationWithDescription("getting_posts")
        _ = network?.getPosts { posts, error in
            XCTAssertNil(error, error!.message)
            XCTAssertNotNil(posts)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10) { [weak self] error in
            guard let error = error else { return }
            self?.recordFailureWithDescription(error.debugDescription, inFile: #file, atLine: #line, expected: false)
        }
    }
    
    func testDownloadingAPhoto() {
        let expectation = expectationWithDescription("downloading_photo")
        _ = network?.getPhoto("one.jpg") { image, error in
            XCTAssertNil(error, error!.message)
            XCTAssertNotNil(image)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10) { [weak self] error in
            guard let error = error else { return }
            self?.recordFailureWithDescription(error.debugDescription, inFile: #file, atLine: #line, expected: false)
        }
    }
    
}
