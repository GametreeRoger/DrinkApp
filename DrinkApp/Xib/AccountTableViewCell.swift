//
//  AccountTableViewCell.swift
//  DrinkApp
//
//  Created by 張又壬 on 2021/11/11.
//

import UIKit

class AccountTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var classTextField: UITextField!
    
    @IBOutlet weak var constellationTextField: UITextField!
    
    @IBOutlet weak var sendOrderButton: UIButton!
    
    var accountCallback: ((String, String, String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let picker: UIPickerView
        picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.tintColor = UIColor.systemBlue
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        var titleLabel = UIBarButtonItem(title: "星座", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        titleLabel.setTitleTextAttributes([.foregroundColor : UIColor.black], for: .disabled)
        titleLabel.isEnabled = false
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(self.cancelPicker))

        toolBar.setItems([cancelButton, spaceButton, titleLabel, spaceButton, doneButton], animated: true)
        constellationTextField.inputView = picker
        constellationTextField.inputAccessoryView = toolBar
        
        classTextField.text = "彼得潘202107"
        sendOrderButton.layer.cornerRadius = 5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func initAccount(accountCallback: @escaping (String, String, String) -> Void) {
        self.accountCallback = accountCallback
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
    }
    
    @IBAction func onOK(_ sender: Any) {
        guard let name = nameTextField.text,
              let className = classTextField.text,
              let constellation = constellationTextField.text,
              !name.isEmpty, !className.isEmpty, !constellation.isEmpty else {
                  return
              }
        accountCallback?(name, className, constellation)
    }
    
    @objc func cancelPicker() {
        constellationTextField.text = ""
        constellationTextField.resignFirstResponder()
    }
    
    @objc func donePicker() {
        constellationTextField.resignFirstResponder()
    }
}

extension AccountTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        Constellation.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Constellation.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        constellationTextField.text = Constellation.allCases[row].rawValue
    }
}
