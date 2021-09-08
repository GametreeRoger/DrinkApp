//
//  DrinkTableViewCell.swift
//  DrinkTableViewCell
//
//  Created by 張又壬 on 2021/8/31.
//

import UIKit

class DrinkTableViewCell: UITableViewCell {

    @IBOutlet weak var DrinkImageView: UIImageView!
    
    @IBOutlet weak var NameLabel: UILabel!
    
    @IBOutlet weak var TempertureLabel: UILabel!
    
    @IBOutlet weak var MonthLimitedLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
