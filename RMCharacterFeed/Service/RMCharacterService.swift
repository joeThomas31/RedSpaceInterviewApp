//
//  RMCharacterService.swift
//  RMCharacterFeed
//
//  Created by Joe Thomas on 2022-11-13.
//

import Foundation

protocol RMCharacterServiceProtocol {
    func getRMCharacters(completion: @escaping (_ success: Bool, _ results: RMResult?, _ error: String?) -> ())
}

struct Constants {
    static let rmCharcaterURL = "https://rickandmortyapi.com/api/character"
    static let parsingErrorMessage = "Error: Trying to parse Characters to model"
    static let getRequestErrorMessage = "Error: Characters GET Request failed"
}
class RMCharacterService: RMCharacterServiceProtocol {
    
    func getRMCharacters(completion: @escaping (Bool, RMResult?, String?) -> ()) {
        HttpRequest().GET(url: Constants.rmCharcaterURL, params: ["": ""], httpHeader: .application_json) { success, data in
            if success {
                do {
                    let model = try JSONDecoder().decode(RMResult.self, from: data!)
                    completion(true, model, nil)
                } catch {
                    completion(false, nil, "\(Constants.parsingErrorMessage): \(error)")
                }
            } else {
                completion(false, nil, Constants.getRequestErrorMessage)
            }
        }
    }
}
