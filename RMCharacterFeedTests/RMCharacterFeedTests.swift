//
//  RMCharacterFeedTests.swift
//  RMCharacterFeedTests
//
//  Created by Joe Thomas on 2022-11-16.
//

import XCTest

final class RMCharacterFeedTests: XCTestCase {

// I want to do TDD for fetching items from remote API
// To do networking I need a client to make the request and an object to make the request and load things for me
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }


}

// Development seen below
class RemoteFeedLoader
{
    private let url: URL
    var client: HTTPClientSpy = HTTPClientSpy()
    init(url: URL, client: HTTPClientSpy) {
        self.url = url
        self.client = client
    }
    
    func load(completion:(Result<Any, Error>)->Void) {
        client.requestedURLs.append(url)
    }
    
    
}

class HTTPClientSpy {
    var requestedURLs: [URL] = []
}
