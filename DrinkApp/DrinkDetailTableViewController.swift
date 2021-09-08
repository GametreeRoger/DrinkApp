//
//  DrinkDetailTableViewController.swift
//  DrinkDetailTableViewController
//
//  Created by 張又壬 on 2021/9/1.
//

import UIKit

class DrinkDetailTableViewController: UITableViewController {

    let DEFAULT_CLASS_NAME = "彼得潘202107"
    let field : DrinkField!
    var orderID = ""
    
    @IBOutlet weak var drinkImageView: UIImageView!

    @IBOutlet weak var coldButton: UIButton! {
        didSet {
            coldButton.configurationUpdateHandler = updateTempertureButton
        }
    }
    @IBOutlet weak var hotButton: UIButton! {
        didSet {
            hotButton.configurationUpdateHandler = updateTempertureButton
        }
    }
    @IBOutlet weak var smoothieLabel: UILabel!
    
    @IBOutlet weak var crushedSmoothieLabel: UILabel!
    
    @IBOutlet var iceButtons: [UIButton]! {
        didSet {
            iceButtons.forEach{ $0.configurationUpdateHandler = updateRadioButton }
        }
    }
    
    @IBOutlet var sugarButtons: [UIButton]! {
        didSet {
            sugarButtons.forEach{ $0.configurationUpdateHandler = updateRadioButton }
        }
    }
    
    @IBOutlet var flavorButtons: [UIButton]! {
        didSet {
            flavorButtons.forEach { $0.configurationUpdateHandler = updateCheckBoxButton }
        }
    }
    
    @IBOutlet weak var largeDrinkButton: UIButton! {
        didSet {
            largeDrinkButton.configurationUpdateHandler = updateRadioButton
        }
    }
    @IBOutlet weak var bottleDrinkButton: UIButton! {
        didSet {
            bottleDrinkButton.configurationUpdateHandler = updateRadioButton
        }
    }
    
    @IBOutlet weak var drinkPriceLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var classTextField: UITextField!
    
    @IBOutlet weak var constellationTextField: UITextField!
    
    @IBOutlet var starPickerView: UIPickerView!
    
    @IBOutlet var starPickerToolbar: UIToolbar!
    
    @IBOutlet weak var toolbarTitleItemButton: UIBarButtonItem!
    
    @IBOutlet weak var drinkQuantityLabel: UILabel!
    
    var tempertuar = Temperture.cold
    var ice = DrinkIce.no
    var sugar = DrinkSugar.no
    var flavorList = Dictionary<Flavor, Bool>()
    var size = DrinkSize.large
    var sectionTitles = ["", "溫度", "冰塊", "甜度", "添加口感", "價格", "帳號"]
    var drinkQuantity = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flavor.allCases.forEach { flavorList[$0] = false }
        
        initDrinkMenu()
    }
    
    func initDrinkMenu() {
        if let imageUrl = field.realImage {
            NetworkController.shared.fetchImage(imageUrl: imageUrl) { image in
                if let image = image {
                    DispatchQueue.main.async {
                        self.drinkImageView.image = image
                    }
                }
            }
        }
        
        coldButton.isHidden = true
        hotButton.isHidden = true
        smoothieLabel.isHidden = true
        crushedSmoothieLabel.isHidden = true
        field.temperature.forEach { temperture in
            if let temp = Temperture(rawValue: temperture) {
                switch temp {
                case .cold:
                    coldButton.isHidden = false
                    coldButton.isSelected = true
                    self.tempertuar = .cold
                case .hot:
                    hotButton.isHidden = false
                case .smoothie:
                    smoothieLabel.isHidden = false
                    self.tempertuar = .smoothie
                case .crushedSmoothie:
                    crushedSmoothieLabel.isHidden = false
                    self.tempertuar = .crushedSmoothie
                }
            }
        }
        
        if isDrinkConstraints(constraint: .iceFixed) {
            sectionTitles[2] = DrinkConstraints.iceFixed.rawValue
        } else {
            setDefaultIce()
        }
        if isDrinkConstraints(constraint: .sugarFixed) {
            sectionTitles[3] = DrinkConstraints.sugarFixed.rawValue
        } else {
            setDefaultSugar()
        }
        
        if var config = largeDrinkButton.configuration {
            config.title = "\(DrinkSize.large.rawValue) \(field.largePrice) 元"
            largeDrinkButton.configuration = config
        }
        largeDrinkButton.isSelected = true
        
        if let bottlePrice = field.bottlePrice {
            if var config = bottleDrinkButton.configuration {
                config.title = "\(DrinkSize.bottle.rawValue) \(bottlePrice) 元"
                bottleDrinkButton.configuration = config
            }
        } else {
            bottleDrinkButton.isHidden = true
        }
        computePrice()
        
        toolbarTitleItemButton.setTitleTextAttributes([.foregroundColor : UIColor.black], for: .disabled)
        constellationTextField.inputView = starPickerView
        constellationTextField.inputAccessoryView = starPickerToolbar
    }
    
    func setDefaultIce() {
        iceButtons.forEach { button in
            let drinkice = DrinkIce.getDrinkIce(tag: button.tag)
            if drinkice == .no {
                button.isSelected = true
            }
        }
    }
    
    func setDefaultSugar() {
        sugarButtons.forEach { button in
            let drinksugar = DrinkSugar.getDrinkSugar(tag: button.tag)
            if drinksugar == .no {
                button.isSelected = true
            }
        }
    }
    
    func selectedFlavors() -> [String] {
        flavorList.filter { $0.value }.map { $0.key.rawValue }
    }
    
    func priceSum() -> Int {
        var sum = 0
        if largeDrinkButton.isSelected {
            sum += field.largePrice
        } else {
            if let bottlePrice = field.bottlePrice {
                sum += bottlePrice
            }
        }
        
        for (key, value) in flavorList {
            if value {
                sum += key.price
            }
        }
        sum *= drinkQuantity
        return sum
    }
    
    func computePrice() {
        let sum = priceSum()
        
        drinkPriceLabel.text = "\(sum) 元"
    }
    
    init?(coder: NSCoder, field: DrinkField) {
        self.field = field
        super.init(coder: coder)
    }
    
    init?(coder: NSCoder, field: DrinkField, orderID: String) {
        self.field = field
        self.orderID = orderID
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isDrinkConstraints(constraint: DrinkConstraints) -> Bool {
        if let fieldConstraints = field.constraints {
            for cons in fieldConstraints {
                if let con = DrinkConstraints(rawValue: cons) {
                    if con == constraint {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func updateTempertureButton(button: UIButton) {
        if var config = button.configuration {
            var configBackground = config.background
            configBackground.backgroundColor = UIColor(named: button.isSelected ? "MainColor" : "SecondColor")
            config.background = configBackground
            config.baseForegroundColor = UIColor(named: button.isSelected ? "SecondColor" : "MainColor")
            button.configuration = config
        }
    }
    
    func updateRadioButton(button: UIButton) {
        if var config = button.configuration {
            config.image = UIImage(systemName: button.isSelected ? "circle.inset.filled" : "circle")
            button.configuration = config
        }
    }
    
    func updateCheckBoxButton(button: UIButton) {
        if var config = button.configuration {
            config.image = UIImage(systemName: button.isSelected ? "checkmark.square" : "square")
            button.configuration = config
        }
    }
    
    func showWarnningAlert(title: String, message: String) {
        let warnningController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        warnningController.addAction(okAction)
        present(warnningController, animated: true, completion: nil)
    }

    @IBAction func selectTemperture(_ sender: UIButton) {
        coldButton.isSelected = sender == coldButton
        hotButton.isSelected = sender != coldButton
        
        self.tempertuar = coldButton.isSelected ? .cold : .hot
        
        tableView.reloadData()
    }
    
    @IBAction func selectIce(_ sender: UIButton) {
        iceButtons.forEach { button in
            if button == sender {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
        
        self.ice = DrinkIce.getDrinkIce(tag: sender.tag)
    }
    
    @IBAction func selectSugar(_ sender: UIButton) {
        sugarButtons.forEach{ button in
            if button == sender {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
        
        self.sugar = DrinkSugar.getDrinkSugar(tag: sender.tag)
    }
    
    @IBAction func selectFlavor(_ sender: UIButton) {
        flavorButtons.forEach { button in
            if button == sender {
                let key = Flavor.getFlavor(tag: sender.tag)
                flavorList[key] = sender.isSelected
            }
        }
        computePrice()
    }
    
    @IBAction func selectDrinkSize(_ sender: UIButton) {
        largeDrinkButton.isSelected = sender == largeDrinkButton
        bottleDrinkButton.isSelected = sender == bottleDrinkButton
        self.size = largeDrinkButton.isSelected ? .large : .bottle
        computePrice()
    }
    
    @IBAction func onOK(_ sender: Any) {
        guard let name = nameTextField.text,
        let className = classTextField.text,
        let constellation = constellationTextField.text,
        !name.isEmpty, !className.isEmpty, !constellation.isEmpty else {
            return
        }
        
        let order = OrderField(name: name, constellation: constellation, className: className, drinkName: field.name, temperture: tempertuar.rawValue, ice: tempertuar == .cold ? ice.rawValue : nil, sugar: isDrinkConstraints(constraint: .sugarFixed) ? nil : sugar.rawValue, flavor: selectedFlavors(), size: size.rawValue, quantity: drinkQuantity, sum: priceSum())
        let orderRecords = OrderRecords(records: [OrderRecord(fields: order, id: orderID.isEmpty ? nil : orderID)])
        
        if orderID.isEmpty {
            NetworkController.shared.createOrder(order: orderRecords) { result in
                switch result {
                case .success(let content):
                    print("createOrder:\(content)")
                    DispatchQueue.main.async {
                        if let navController = self.navigationController {
                            let count = navController.viewControllers.count
                            if let controller = navController.viewControllers[count - 3] as? OrderTableViewController {
                                navController.popToViewController(controller, animated: true)
                            }
                        }
                    }
                case .failure(let error):
                    self.showWarnningAlert(title: "Warnning", message: "新增訂單失敗:\(error)")
                }
            }
        } else {
            NetworkController.shared.updateOrder(order: orderRecords) { result in
                switch result {
                case .success(let content):
                    self.orderID = ""
                    print("updateOrder:\(content)")
                    DispatchQueue.main.async {
                        if let navController = self.navigationController {
                            let count = navController.viewControllers.count
                            if let drinkcontroller = navController.viewControllers[count - 2] as? DrinkTableViewController {
                                drinkcontroller.orderID = ""
                            }
                            if let controller = navController.viewControllers[count - 3] as? OrderTableViewController {
                                navController.popToViewController(controller, animated: true)
                            }
                        }
                    }
                case .failure(let error):
                    self.showWarnningAlert(title: "Warnning", message: "修改訂單失敗:\(error)")
                }
            }
        }
    }
    
    @IBAction func onCancelStar(_ sender: Any) {
        constellationTextField.text = ""
        constellationTextField.resignFirstResponder()
    }
    
    @IBAction func onDoneStar(_ sender: Any) {
        constellationTextField.resignFirstResponder()
    }
    
    @IBAction func onDrinkQuantity(_ sender: UIStepper) {
        drinkQuantityLabel.text = String(format: "%.0f", arguments: [sender.value])
        drinkQuantity = Int(sender.value)
        computePrice()
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            if coldButton.isSelected {
                return 50
            } else {
                return 0.0
            }
        } else {
            return 50
        }
//        return UITableView.automaticDimension
    }
    
    func getSectionHeaderView(title: String) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        
        view.backgroundColor = UIColor.clear
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: view.bounds.width - 10, height: 50))
        label.text = title
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 30)
        
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return getSectionHeaderView(title: field.name)
        } else if section == 2 {
            if coldButton.isSelected || isDrinkConstraints(constraint: .iceFixed) {
                return getSectionHeaderView(title: sectionTitles[section])
            } else {
                return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            }
        } else {
            return getSectionHeaderView(title: sectionTitles[section])
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            if isDrinkConstraints(constraint: .iceFixed) {
                return 0
            }
            return coldButton.isSelected ? 1 : 0
        } else if section == 3 {
            return isDrinkConstraints(constraint: .sugarFixed) ? 0 : 1
        } else {
            return 1
        }
    }
}

extension DrinkDetailTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
