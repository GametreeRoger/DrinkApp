//
//  FlavorTableViewCell.swift
//  DrinkApp
//
//  Created by 張又壬 on 2021/11/10.
//

import UIKit

class FlavorTableViewCell: UITableViewCell {

    @IBOutlet var flavorButtons: [UIButton]!
    
    var flavorCallback: ((Flavor, Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initFlavor(callback: @escaping (Flavor, Bool) -> Void) {
        flavorCallback = callback
    }
    
    func updateCheckBoxButton(button: UIButton) {
        button.setImage(UIImage(systemName: button.isSelected ? "checkmark.square" : "square"), for: .normal)
    }
    
    @IBAction func onFlavor(_ sender: UIButton) {
        flavorButtons.forEach { button in
            if button == sender {
                button.isSelected.toggle()
                let key = Flavor.getFlavor(tag: sender.tag)
                flavorCallback?(key, button.isSelected)
//                flavorList[key] = button.isSelected
                updateCheckBoxButton(button: button)
            }
        }
    }
    
}
