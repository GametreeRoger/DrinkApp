//
//  TempertureTableViewCell.swift
//  DrinkApp
//
//  Created by 張又壬 on 2021/11/10.
//

import UIKit

class TempertureTableViewCell: UITableViewCell {
    @IBOutlet weak var coldButton: UIButton!
    
    @IBOutlet weak var hotButton: UIButton!
    
    @IBOutlet weak var smoothieLabel: UILabel!
    
    @IBOutlet weak var crushedSmoothieLabel: UILabel!
    
    var tempertureCallback: ((Temperture) -> Void)?
    var isInit = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        coldButton.isHidden = true
        hotButton.isHidden = true
        smoothieLabel.isHidden = true
        crushedSmoothieLabel.isHidden = true
        
        coldButton.backgroundColor = .clear
        coldButton.layer.cornerRadius = 5
        coldButton.layer.borderWidth = 1
        coldButton.layer.borderColor = UIColor(named: "MainColor")?.cgColor
        hotButton.backgroundColor = .clear
        hotButton.layer.cornerRadius = 5
        hotButton.layer.borderWidth = 1
        hotButton.layer.borderColor = UIColor(named: "MainColor")?.cgColor
        coldButton.isSelected = true
        updateTempertureButton(button: coldButton)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initTemperture(tempertures: [String], callback: @escaping (Temperture) -> Void) {
        guard !isInit else {
            return
        }
        
        isInit = true
        tempertureCallback = callback
        tempertures.forEach { temperture in
            if let temp = Temperture(rawValue: temperture) {
                switch temp {
                case .cold:
                    coldButton.isHidden = false
                    coldButton.isSelected = true
                    callback(.cold)
                case .hot:
                    hotButton.isHidden = false
                case .smoothie:
                    smoothieLabel.isHidden = false
                    callback(.smoothie)
                case .crushedSmoothie:
                    crushedSmoothieLabel.isHidden = false
                    callback(.crushedSmoothie)
                }
            }
        }
    }
    
    func updateTempertureButton(button: UIButton) {
        button.backgroundColor = UIColor(named: button.isSelected ? "MainColor" : "SecondColor")
        button.setTitleColor(UIColor(named: button.isSelected ? "SecondColor" : "MainColor"), for: .normal)
    }
    
    @IBAction func onTemperture(_ sender: UIButton) {
        coldButton.isSelected = sender == coldButton
        hotButton.isSelected = sender != coldButton
        updateTempertureButton(button: coldButton)
        updateTempertureButton(button: hotButton)
        tempertureCallback?(coldButton.isSelected ? .cold : .hot)
    }
    
}
