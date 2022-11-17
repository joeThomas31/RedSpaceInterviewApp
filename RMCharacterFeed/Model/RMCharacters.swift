//
//  RMCharacters.swift
//  RMCharacterFeed
//
//  Created by Joe Thomas on 2022-11-13.
//


struct RMResult: Codable, Equatable {
    let results: [RMCharacter]
    
    static func == (lhs: RMResult, rhs: RMResult) -> Bool {
        return lhs.results == rhs.results
    }
}

struct RMCharacter: Codable, Equatable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let gender: String
    let location: [String:String]
    let image: String
    let episode: [String]
    
    static func == (lhs: RMCharacter, rhs: RMCharacter) -> Bool {
        return lhs.id == rhs.id
    }
}

struct RMLocation: Codable {
    let name: String
}
