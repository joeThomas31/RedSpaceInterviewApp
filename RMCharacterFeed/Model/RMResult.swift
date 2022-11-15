//
//  RMResult.swift
//  RMCharacterFeed
//
//  Created by Joe Thomas on 2022-11-13.
//

import Foundation

struct RMResult: Codable, Equatable {
    static func == (lhs: RMResult, rhs: RMResult) -> Bool {
        return lhs.info == rhs.info && lhs.results == rhs.results
    }
    
    let info: RMInfo
    let results: [RMCharacter]

    enum CodingKeys: String, CodingKey {
        case info
        case results
    }
}

struct RMInfo: Codable, Equatable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?

    enum CodingKeys: String, CodingKey {
        case count
        case pages
        case next
        case prev
    }
}
