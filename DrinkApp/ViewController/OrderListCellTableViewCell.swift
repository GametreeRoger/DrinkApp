//
//  OrderListCellTableViewCell.swift
//  OrderListCellTableViewCell
//
//  Created by 張又壬 on 2021/9/13.
//

import UIKit

class OrderListCellTableViewCell: UITableViewCell {

    @IBOutlet weak var drinkNameLabel: UILabel!
    
    @IBOutlet weak var tempertureLabel: UILabel!
    
    @IBOutlet weak var flavorLabel: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
