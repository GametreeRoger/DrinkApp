//
//  DrinkDetailXibTableViewController.swift
//  DrinkApp
//
//  Created by 張又壬 on 2021/11/11.
//

import UIKit

class DrinkDetailXibTableViewController: UITableViewController {

    let field : DrinkField!
    var orderID = ""
    
    var tempertuar = Temperture.cold
    var ice = DrinkIce.no
    var sugar = DrinkSugar.no
    var flavorList = Dictionary<Flavor, Bool>()
    var size = DrinkSize.large
    var sectionTitles = ["", "溫度", "冰塊", "甜度", "添加口感", "價格", "帳號"]
    var reuseIds = [String]()
    var drinkQuantity = 1
    var priceCallback: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Flavor.allCases.forEach { flavorList[$0] = false }
        
        reuseIds = ["\(DrinkPictureTableViewCell.self)", "\(TempertureTableViewCell.self)", "\(IceTableViewCell.self)", "\(SugarTableViewCell.self)", "\(FlavorTableViewCell.self)", "\(PriceTableViewCell.self)", "\(AccountTableViewCell.self)"]
        
        reuseIds.forEach { tableView.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0) }
        
        if isDrinkConstraints(constraint: .iceFixed) {
            sectionTitles[2] = DrinkConstraints.iceFixed.rawValue
        }
        if isDrinkConstraints(constraint: .sugarFixed) {
            sectionTitles[3] = DrinkConstraints.sugarFixed.rawValue
        }
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
    
    func selectedFlavors() -> [String] {
        flavorList.filter { $0.value }.map { $0.key.rawValue }
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
    
    func priceSum() -> Int {
        var sum = 0
        if size == .large {
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
        
        priceCallback?(sum)
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
    
    func showWarnningAlert(title: String, message: String) {
        let warnningController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        warnningController.addAction(okAction)
        present(warnningController, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            if tempertuar == .cold || isDrinkConstraints(constraint: .iceFixed) {
                return 50
            } else {
                return 0.0
            }
        } else {
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return getSectionHeaderView(title: field.name)
        } else if section == 2 {
            if tempertuar == .cold || isDrinkConstraints(constraint: .iceFixed) {
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
            return tempertuar == .cold ? 1 : 0
        } else if section == 3 {
            return isDrinkConstraints(constraint: .sugarFixed) ? 0 : 1
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionIndex = indexPath.section
        let reuseId = reuseIds[sectionIndex]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
        switch cell {
        case let cell as DrinkPictureTableViewCell:
            if let imageUrl = field.realImage {
                NetworkController.shared.fetchImage(imageUrl: imageUrl) { image in
                    if let image = image {
                        DispatchQueue.main.async {
                            cell.drinkPicture.image = image
                        }
                    }
                }
            }
        case let cell as TempertureTableViewCell:
            cell.initTemperture(tempertures: field.temperature) {
                self.tempertuar = $0
                self.tableView.reloadData()
            }
        case let cell as IceTableViewCell:
            cell.initIce {
                self.ice = $0
            }
        case let cell as SugarTableViewCell:
            cell.initSugar {
                self.sugar = $0
            }
        case let cell as FlavorTableViewCell:
            cell.initFlavor {
                self.flavorList[$0] = $1
                self.computePrice()
            }
        case let cell as PriceTableViewCell:
            priceCallback = cell.updatePrice
            cell.initSizeAndQuantity(price: priceSum()) {
                self.size = $0
                self.computePrice()
            } quantityCallback: {
                self.drinkQuantity = $0
                self.computePrice()
            }
        case let cell as AccountTableViewCell:
            cell.initAccount { name, className, constellation in
                let order = OrderField(name: name, constellation: constellation, className: className, drinkName: self.field.name, temperture: self.tempertuar.rawValue, ice: self.tempertuar == .cold ? self.ice.rawValue : nil, sugar: self.isDrinkConstraints(constraint: .sugarFixed) ? nil : self.sugar.rawValue, flavor: self.selectedFlavors(), size: self.size.rawValue, quantity: self.drinkQuantity, sum: self.priceSum())
                let orderRecords = OrderRecords(records: [OrderRecord(fields: order, id: self.orderID.isEmpty ? nil : self.orderID)])
                
                if self.orderID.isEmpty {
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
                            print("updateOrder:\(content)")
                            self.orderID = ""
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
        default:
            return cell
        }

        return cell
    }
}
