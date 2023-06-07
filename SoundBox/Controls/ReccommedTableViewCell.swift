//
//  ReccommedTableViewCell.swift
//  SoundBox
//
//  Created by Long Nguyễn Thành on 07/05/2023.
//

import UIKit

class ReccommedTableViewCell: UITableViewCell {
    //MARK: propeties
    @IBOutlet weak var imgSong: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSinger: UILabel!
    @IBOutlet weak var lblListens: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
