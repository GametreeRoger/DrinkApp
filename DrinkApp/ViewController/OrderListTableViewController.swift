//
//  OrderListTableViewController.swift
//  OrderListTableViewController
//
//  Created by 張又壬 on 2021/9/13.
//

import UIKit
import AVFoundation

class OrderListTableViewController: UITableViewController {

    var orderRecords = [OrderRecord]()
    var fields = [OrderListField]()
    let synthesizer = AVSpeechSynthesizer()
    var speakArray = [String]()
    
    var speakerButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "飲料訂單"
        synthesizer.mixToTelephonyUplink = true
        synthesizer.delegate = self
        
        let orderListFields = orderRecords.map { record in
            OrderListField(drinkName: record.fields.drinkName, temperture: record.fields.temperture, ice: record.fields.ice, sugar: record.fields.sugar, flavor: record.fields.flavor, size: record.fields.size, quantity: record.fields.quantity, sum: record.fields.sum)
        }
        let orderDic = Dictionary(grouping: orderListFields) { $0 }
        for (key, value) in orderDic {
            var tempField = key
            tempField.quantity = 0
            tempField.sum = 0
            for listField in value {
                tempField.quantity += listField.quantity
                tempField.sum += listField.sum
            }
            fields.append(tempField)
        }
        fields.sort { $0.drinkName < $1.drinkName }
    }
    
    func speak(text: String, delay: Double = 0) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
        speechUtterance.rate = 0.4
        speechUtterance.postUtteranceDelay = delay
        synthesizer.speak(speechUtterance)
    }
    
    func getSpeakerTempertureText(field: OrderListField) -> String {
        var tempArray = [String]()
        if field.temperture == Temperture.hot.rawValue {
            tempArray.append(field.temperture.appending("的"))
        }
        if let ice = field.ice {
            tempArray.append(ice)
        }
        if var sugar = field.sugar {
            if !sugar.hasSuffix("糖") {
                sugar.append("糖")
            }
            tempArray.append(sugar)
        }
        return tempArray.joined(separator: ", ")
    }
    
    func getSpeakerFlavorText(field: OrderListField) -> String {
        if let flavors = field.flavor {
            return "加上 \(flavors.joined(separator: " 和 "))"
        } else {
            return ""
        }
    }
    
    func getSpeakArray() -> [String] {
        if speakArray.count == 0 {
            for field in fields {
                let temperture = getSpeakerTempertureText(field: field)
                let flavortext = getSpeakerFlavorText(field: field)
                let size = DrinkSize.large.rawValue == field.size ? DrinkSize.large : DrinkSize.bottle
                let quantitytext = size.getOrderName(quantity: field.quantity)
                let speakText = "\(field.drinkName) \(temperture) \(flavortext) \(quantitytext) \n"
                speakArray.append(speakText)
            }
        }
        return speakArray
    }
    
    func speakButtonColor(isSpeaking: Bool) {
//        if var config = speakerButton.configuration {
//            config.baseForegroundColor = isSpeaking ? .red : .white
//            speakerButton.configuration = config
//        }
        speakerButton.tintColor = isSpeaking ? .red : .white
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fields.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        40
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        let cornerView = UIView()
        cornerView.backgroundColor = .systemBrown
        cornerView.layer.cornerRadius = 10
        footerView.addSubview(cornerView)
        speakerButton.addAction(UIAction(handler: { _ in
            if self.synthesizer.isSpeaking {
                self.synthesizer.stopSpeaking(at: .immediate)
                self.speakButtonColor(isSpeaking: false)
            } else {
                self.getSpeakArray().forEach { self.speak(text: $0, delay: 0.8) }
                self.speakButtonColor(isSpeaking: true)
            }
        }), for: .primaryActionTriggered)
        speakerButton.setImage(UIImage(systemName: "wave.3.forward.circle"), for: .normal)
//        speakerButton = UIButton(configuration: .plain(), primaryAction: UIAction(title: "", image: UIImage(systemName: "person.wave.2.fill"), handler: { _ in
//            if self.synthesizer.isSpeaking {
//                self.synthesizer.stopSpeaking(at: .immediate)
//                self.speakButtonColor(isSpeaking: false)
//            } else {
//                self.getSpeakArray().forEach { self.speak(text: $0, delay: 0.8) }
//                self.speakButtonColor(isSpeaking: true)
//            }
//        }))
        speakButtonColor(isSpeaking: false)
        cornerView.addSubview(speakerButton)
        let phoneButton = UIButton()
        phoneButton.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        phoneButton.addAction(UIAction(handler: { _ in
            if let storeController = self.storyboard?.instantiateViewController(withIdentifier: "\(StoreTableViewController.self)") as? StoreTableViewController {
                storeController.phoneDelegate = self
                self.present(storeController, animated: true, completion: nil)
            }
        }), for: .primaryActionTriggered)
        
//        let phoneButton = UIButton(configuration: .plain(), primaryAction: UIAction(title: "", image: UIImage(systemName: "phone.fill"), handler: { _ in
//            if let storeController = self.storyboard?.instantiateViewController(withIdentifier: "\(StoreTableViewController.self)") as? StoreTableViewController {
//                storeController.phoneDelegate = self
//                self.present(storeController, animated: true, completion: nil)
//            }
//        }))
//        if var config = phoneButton.configuration {
//            config.baseForegroundColor = .white
//            phoneButton.configuration = config
//        }
        phoneButton.tintColor = .white
        cornerView.addSubview(phoneButton)
        let priceLabel = UILabel()
        let sum = fields.reduce(0) { $0 + $1.sum }
        priceLabel.text = "\(sum) 元"
        priceLabel.textColor = .white
        cornerView.addSubview(priceLabel)
        
        cornerView.translatesAutoresizingMaskIntoConstraints = false
        speakerButton.translatesAutoresizingMaskIntoConstraints = false
        phoneButton.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cornerView.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 5).isActive = true
        cornerView.bottomAnchor.constraint(equalTo: footerView.bottomAnchor).isActive = true
        cornerView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor).isActive = true
        cornerView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor).isActive = true
        speakerButton.centerYAnchor.constraint(equalTo: cornerView.centerYAnchor).isActive = true
        speakerButton.leadingAnchor.constraint(equalTo: cornerView.leadingAnchor, constant: 10).isActive = true
        phoneButton.centerYAnchor.constraint(equalTo: cornerView.centerYAnchor).isActive = true
        phoneButton.leadingAnchor.constraint(equalTo: speakerButton.trailingAnchor, constant: 10).isActive = true
        priceLabel.centerYAnchor.constraint(equalTo: cornerView.centerYAnchor).isActive = true
        priceLabel.trailingAnchor.constraint(equalTo: cornerView.trailingAnchor, constant: -10).isActive = true
        
        return footerView
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(OrderListCellTableViewCell.self)", for: indexPath) as? OrderListCellTableViewCell else {
            return UITableViewCell()
        }

        let field = fields[indexPath.row]
        cell.drinkNameLabel.text = field.drinkName
        
        cell.tempertureLabel.text = getSpeakerTempertureText(field: field)
        
        cell.flavorLabel.text = getSpeakerFlavorText(field: field)
        
        let size = DrinkSize.large.rawValue == field.size ? DrinkSize.large : DrinkSize.bottle
        cell.quantityLabel.text = size.getOrderName(quantity: field.quantity)
        cell.priceLabel.text = "\(field.sum) 元"

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OrderListTableViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if let lastSpeak = speakArray.last, lastSpeak == utterance.speechString {
            // finish
            speakButtonColor(isSpeaking: false)
        }
    }
}

extension OrderListTableViewController: PhoneDelegate {
    func callPhoneNumber(phones: [String]) {
        let alertController = UIAlertController(title: "訂飲料", message: nil, preferredStyle: .actionSheet)
        phones.forEach { phone in
            let alertAction = UIAlertAction(title: phone, style: .default) { action in
                self.callNumber(phoneNumber: phone)
            }
            alertController.addAction(alertAction)
        }
        let alertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func callNumber(phoneNumber: String) {
        guard let url = URL(string: "telprompt://\(phoneNumber)"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
