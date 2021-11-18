//
//  IceTableViewCell.swift
//  DrinkApp
//
//  Created by 張又壬 on 2021/11/10.
//

import UIKit

class IceTableViewCell: UITableViewCell {

    @IBOutlet var iceButtons: [UIButton]!
    
    var iceCallback: ((DrinkIce) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iceButtons.forEach { icebtn in
//            icebtn.setTitle("", for: .normal)
            if icebtn.tag == 0 {
                icebtn.isSelected = true
                updateRadioButton(button: icebtn)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initIce(callback: @escaping (DrinkIce) -> Void) {
        iceCallback = callback
        
    }
    
    func updateRadioButton(button: UIButton) {
        button.setImage(UIImage(systemName: button.isSelected ? "record.circle" : "circle"), for: .normal)
    }
    
    @IBAction func onIce(_ sender: UIButton) {
        iceButtons.forEach { button in
            if button == sender {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
            updateRadioButton(button: button)
        }
        
        iceCallback?(DrinkIce.getDrinkIce(tag: sender.tag))
//        self.ice = DrinkIce.getDrinkIce(tag: sender.tag)
    }
}
