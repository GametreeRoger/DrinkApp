//
//  PriceTableViewCell.swift
//  DrinkApp
//
//  Created by 張又壬 on 2021/11/10.
//

import UIKit

class PriceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var largeDrinkButton: UIButton!
    
    @IBOutlet weak var bottleDrinkButton: UIButton!
    
    @IBOutlet weak var drinkQuantityLabel: UILabel!
    
    @IBOutlet weak var drinkPriceLabel: UILabel!
    
    var quantityCallback: ((Int) -> Void)?
    var sizeCallback: ((DrinkSize) -> Void)?
    var isInit = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        largeDrinkButton.isSelected = true
        updateRadioButton(button: largeDrinkButton)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateRadioButton(button: UIButton) {
        button.setImage(UIImage(systemName: button.isSelected ? "record.circle" : "circle"), for: .normal)
    }
    
    func initSizeAndQuantity(price: Int, sizeCallback: @escaping (DrinkSize) -> Void, quantityCallback: @escaping (Int) -> Void) {
        if !isInit {
            isInit = true
            self.sizeCallback = sizeCallback
            self.quantityCallback = quantityCallback
            self.drinkQuantityLabel.text = "1"
            updatePrice(price: price)
        }
    }
    
    func updatePrice(price: Int) {
        drinkPriceLabel.text = "\(price) 元"
    }
    
    @IBAction func onSize(_ sender: UIButton) {
        largeDrinkButton.isSelected = sender == largeDrinkButton
        bottleDrinkButton.isSelected = sender == bottleDrinkButton
        updateRadioButton(button: largeDrinkButton)
        updateRadioButton(button: bottleDrinkButton)
        sizeCallback?(largeDrinkButton.isSelected ? .large : .bottle)
    }
    
    @IBAction func onQuantity(_ sender: UIStepper) {
        drinkQuantityLabel.text = String(format: "%.0f", arguments: [sender.value])
        quantityCallback?(Int(sender.value))
    }
    
}
