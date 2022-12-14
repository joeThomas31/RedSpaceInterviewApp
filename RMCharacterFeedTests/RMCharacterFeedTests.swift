//
//  RMCharacterFeedTests.swift
//  RMCharacterFeedTests
//
//  Created by Joe Thomas on 2022-11-16.
//
@testable import RMCharacterFeed
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
    
    func test_load_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversInvalidDataErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversInvalidDataErrorOn200HTTPResponseWithPartiallyValidJSONItems() {
        let (sut, client) = makeSUT()

        let validItem = makeItem(id: 1, name: "gsg", status: "hbs", species: "shbj", gender: "jsn", location: ["name":"WonderLand"], image: "djn", episode: []).json
        let invalidItem = ["invalid": "item"]

        let items = [validItem, invalidItem]
        let json = makeItemsJSON(items)
        
        
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let json = makeItemsJSON(items)
            client.complete(withStatusCode: 200, data: json)
        })
    }

    func test_load_deliversSuccessWithNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversSuccessWithItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let validItem1 = makeItem(id: 1, name: "gsg", status: "hbs", species: "shbj", gender: "jsn", location: ["name":"WonderLand"], image: "djn", episode: [])
        let validItem2 = makeItem(id: 2, name: "gsg", status: "hbs", species: "shbj", gender: "jsn", location: ["name":"WonderLand"], image: "djn", episode: [])

        let items = [validItem1.model, validItem2.model]

        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON([validItem1.json, validItem2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    
    // MARK: - Helpers
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data  {
        let json = ["results": items]
        guard JSONSerialization.isValidJSONObject(json) else {
            fatalError("Invalid json object")
        }
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func makeItem(id: Int, name: String, status: String, species: String, gender: String, location: [String:String], image: String, episode: [String]) -> (model: RMCharacter, json: [String: Any]) {
        let item = RMCharacter(id: id, name: name, status: status, species: species, gender: gender, location: location, image: image, episode: episode)

        let json = [
            "id": id,
            "name": name,
            "status": status,
            "species": species,
            "gender": gender,
            "location": location,
            "image": image,
            "episode": episode
        ].compactMapValues { $0 }

        return (item, json)
    }
    
    func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: Result<[RMCharacter], RemoteFeedLoader.Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems as! [RMCharacter], expectedItems, file: file, line: line)

            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        waitForExpectations(timeout: 0.1)
    }


}

// Development seen below
class RemoteFeedLoader
{
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let url: URL
    var client: HTTPClientSpy = HTTPClientSpy()
    
    init(url: URL, client: HTTPClientSpy) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Result<Any, Error>)->Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else {
                return
            }
            switch result {
            case let .success((data, response)):
                if let items = try? FeedItemsMapper.map(data, response) {
                    completion(.success(items))
                } else {
                    completion(Result.failure(Error.invalidData))
                }

            case .failure(_):
                completion(Result.failure(Error.connectivity))
            }

        }
    }
    
    
}

private class FeedItemsMapper {
    static var OK_200: Int { return 200 }

    private struct Root: Decodable {
        let results: [RMCharacter]
    }

    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RMCharacter] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        
        return root.results
    }
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    func get(from url: URL, completion: @escaping (Result) -> Void)
}

class HTTPClientSpy: HTTPClient {
   
    
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()

    var requestedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
        guard messages.count > index else {
            return XCTFail("Can't complete request never made", file: file, line: line)
        }

        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
        guard requestedURLs.count > index else {
            return XCTFail("Can't complete request never made", file: file, line: line)
        }

        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!

        messages[index].completion(.success((data, response)))
    }

}
