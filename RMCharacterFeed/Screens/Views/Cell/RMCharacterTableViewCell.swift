//
//  RMCharacterTableViewCell.swift
//  RMCharacterFeed
//
//  Created by Joe Thomas on 2022-11-13.
//

import UIKit

class RMCharacterTableViewCell: UITableViewCell {

    @IBOutlet weak var rmCharcaterNameLabel: UILabel!
    @IBOutlet weak var rmCharacterEpisodesCountLabel: UILabel!
    @IBOutlet weak var thumbnailImg: UIImageView!
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    var cellViewModel: RMCharacterCellViewModel? {
        didSet {
            rmCharcaterNameLabel.text = cellViewModel?.name
            if let count = cellViewModel?.episode.count {
                rmCharacterEpisodesCountLabel.text = "Episode " + String(count)

            } else {
                rmCharacterEpisodesCountLabel.text = "Episode 0"

            }
            thumbnailImg.image = cellViewModel?.imagePhoto
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }

    func initView() {
        backgroundColor = .clear
        preservesSuperviewLayoutMargins = false
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        rmCharcaterNameLabel.text = nil
        rmCharacterEpisodesCountLabel.text = nil
        thumbnailImg.image = nil
    }
}
