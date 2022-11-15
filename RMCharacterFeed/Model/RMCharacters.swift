//
//  RMCharacters.swift
//  RMCharacterFeed
//
//  Created by Joe Thomas on 2022-11-13.
//


import UIKit

struct RMCharacter: Codable, Equatable {
    static func == (lhs: RMCharacter, rhs: RMCharacter) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: RMLocation
    let location: RMLocation
    let image: String
    let episode: [String]
    let url: String
    let created: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case species
        case type
        case gender
        case origin
        case location
        case image
        case episode
        case url
        case created
    }
}

struct RMLocation: Codable {
    let url: String
    let name: String
    enum CodingKeys: String, CodingKey {
        case url
        case name

        
    }
}
