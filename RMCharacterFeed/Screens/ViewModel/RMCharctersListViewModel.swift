//
//  RMCharctersListViewModel.swift
//  RMCharacterFeed
//
//  Created by Joe Thomas on 2022-11-13.
//

import Foundation
import UIKit

class RMCharctersListViewModel: NSObject {
    private var rmCharacterService: RMCharacterServiceProtocol
    var isFiltering: Bool
    var reloadTableView: (() -> Void)?
    var rmcharacters = [RMCharacter]()
    var rmFilteredCharcatersCellViewModels = [RMCharacterCellViewModel]()
    var rmCharcaterDetailsViewModel = [RMCharcaterDetailsViewModel]()
    var rmCharcatersCellViewModels = [RMCharacterCellViewModel]() {
        didSet {
            reloadTableView?()
        }
    }
   
    init(rmCharacterService: RMCharacterServiceProtocol = RMCharacterService()) {
        self.isFiltering = false
        self.rmCharacterService = rmCharacterService
    }
    
    func getRMCharacters() {
        rmCharacterService.getRMCharacters { success, model, error in
            if success, let result = model {
                self.fetchData(characters: result.results)
            } else {
                print(error!)
            }
        }
    }
    
    func fetchData(characters: [RMCharacter]) {
        self.rmcharacters = characters
        var cvms = [RMCharacterCellViewModel]()
        var dvms = [RMCharcaterDetailsViewModel]()
        for character in characters {
            cvms.append(createCellModel(rmCharacter: character))
            dvms.append(self.createDetailsViewModel(rmCharacter: character))
        }
        rmCharcatersCellViewModels = cvms
        rmFilteredCharcatersCellViewModels = cvms
        rmCharcaterDetailsViewModel = dvms
    }
    
    func filteerCellViewModels(for search: String?) {
        if let search = search {
            rmFilteredCharcatersCellViewModels =  !search.isEmpty ? rmCharcatersCellViewModels.filter({ vm in
                vm.name.lowercased().contains(search.lowercased())
            }) : rmCharcatersCellViewModels
        }
        reloadTableView!()
    }
    
    func createCellModel(rmCharacter: RMCharacter) -> RMCharacterCellViewModel {
        let episode = rmCharacter.episode 
        let name = rmCharacter.name
        let image = rmCharacter.image
        var imagePhoto = UIImage(systemName: "person.and.background.dotted")!
        
        if let data = try? Data(contentsOf: URL(string: image )!) {
            if let image = UIImage(data: data) {
                 imagePhoto = image
            }
        }
        return RMCharacterCellViewModel(episode: episode, name: name , image: image , imagePhoto: imagePhoto)
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> RMCharacterCellViewModel {
        if isFiltering {
            return rmFilteredCharcatersCellViewModels[indexPath.row]
        } else {
            return rmCharcatersCellViewModels[indexPath.row]
        }
    }
    
    func createDetailsViewModel(rmCharacter: RMCharacter) -> RMCharcaterDetailsViewModel {
        let name = rmCharacter.name
        let image = rmCharacter.image
        let status = rmCharacter.status
        let species = rmCharacter.species
      //  let type = rmCharacter.type
        let gender = rmCharacter.gender
        let location = rmCharacter.location
        var imagePhoto = UIImage(systemName: "person.and.background.dotted")!
        if let data = try? Data(contentsOf: URL(string: image )!) {
            if let image = UIImage(data: data) {
                 imagePhoto = image
            }
        }
        
        return RMCharcaterDetailsViewModel(name: name, image: image, status: status, species: species, gender: gender, location: location.name, imagePhoto: imagePhoto)
        

    }
    
    func getDetailsViewModel(at indexPath: IndexPath) -> RMCharcaterDetailsViewModel {
        return rmCharcaterDetailsViewModel[indexPath.row]
    }
}

