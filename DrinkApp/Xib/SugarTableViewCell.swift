//
//  SugarTableViewCell.swift
//  DrinkApp
//
//  Created by 張又壬 on 2021/11/10.
//

import UIKit

class SugarTableViewCell: UITableViewCell {

    @IBOutlet var sugarButtons: [UIButton]!
    
    var sugarCallback: ((DrinkSugar) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sugarButtons.forEach { sugarbtn in
//            sugarbtn.setTitle("", for: .normal)
            if sugarbtn.tag == 0 {
                sugarbtn.isSelected = true
                updateRadioButton(button: sugarbtn)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initSugar(callback: @escaping (DrinkSugar) -> Void) {
        sugarCallback = callback
    }
    
    func updateRadioButton(button: UIButton) {
        button.setImage(UIImage(systemName: button.isSelected ? "record.circle" : "circle"), for: .normal)
    }
    
    @IBAction func onSugar(_ sender: UIButton) {
        sugarButtons.forEach{ button in
            if button == sender {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
            updateRadioButton(button: button)
        }
        
        sugarCallback?(DrinkSugar.getDrinkSugar(tag: sender.tag))
//        self.sugar = DrinkSugar.getDrinkSugar(tag: sender.tag)
    }
    
    
}
