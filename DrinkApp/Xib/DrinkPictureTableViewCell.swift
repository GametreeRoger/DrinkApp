//
//  DrinkPictureTableViewCell.swift
//  DrinkApp
//
//  Created by 張又壬 on 2021/11/10.
//

import UIKit

class DrinkPictureTableViewCell: UITableViewCell {
    
    @IBOutlet weak var drinkPicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
