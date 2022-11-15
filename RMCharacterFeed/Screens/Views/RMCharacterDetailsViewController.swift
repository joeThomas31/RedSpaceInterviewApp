//
//  RMCharacterDetailsViewController.swift
//  RMCharacterFeed
//
//  Created by Joe Thomas on 2022-11-13.
//

import UIKit

class RMCharacterDetailsViewController: UIViewController {
    @IBOutlet weak var rmCharacterImage: UIImageView!
    @IBOutlet weak var rmCharacterStatusLabel: UILabel!
    @IBOutlet weak var rmCharacterSpeciesLabel: UILabel!
    @IBOutlet weak var rmCharacterGenderLabel: UILabel!
    @IBOutlet weak var rmCharacterNameLabel: UILabel!
    @IBOutlet weak var rmCharcaterLocationLabel: UILabel!
    var selecetedCharacter: RMCharcaterDetailsViewModel?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let selected = selecetedCharacter else {
            return
        }
        rmCharacterStatusLabel.text = selected.status
        rmCharacterSpeciesLabel.text = selected.species
        rmCharacterGenderLabel.text = selected.gender
        rmCharacterNameLabel.text = selected.name
        rmCharcaterLocationLabel.text = selected.location
        rmCharacterImage.image = selected.imagePhoto
    }
}
