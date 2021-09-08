//
//  OrderTableViewController.swift
//  OrderTableViewController
//
//  Created by 張又壬 on 2021/9/4.
//

import UIKit

class OrderTableViewController: UITableViewController {

    let ORDER_CELL_ID = "OrderCellID"
    let MENU_SEGUE_ID = "showMenu"
//    let constellation = ["牡羊座", "金牛座", "雙子座", "巨蟹座", "獅子座", "處女座", "天秤座", "天蠍座", "射手座", "魔羯座", "水瓶座", "雙魚座"]
    
    var orderRecords = [OrderRecord]()
    var groupSet = Set<String>()
    var groupArray = [String]()
    let checkStarAlertController = UIAlertController(title: "密碼", message: "認證密碼", preferredStyle: .alert)
    var deleteIndexPath = IndexPath()
    var updateIndexPath = IndexPath()
    var isUpdate = true
    
    @IBOutlet var starPickerView: UIPickerView!
    
    @IBOutlet var starPickerToolbar: UIToolbar!
    
    @IBOutlet weak var toolbarTitleButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initCheckPasswordAlert()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateOrder()
    }
    
    func updateOrder() {
        NetworkController.shared.fetchOrders { result in
            switch result {
            case .success(let orderRecords):
                self.orderRecords = orderRecords
                self.updateGroupArray()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Fetch order failed:\(error)")
            }
        }
    }
    
    func initCheckPasswordAlert() {
        toolbarTitleButtonItem.setTitleTextAttributes([.foregroundColor : UIColor.black], for: .disabled)
        checkStarAlertController.addTextField { textField in
            textField.placeholder = "請輸入星座"
            textField.inputView = self.starPickerView
            textField.inputAccessoryView = self.starPickerToolbar
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            guard let textField = self.checkStarAlertController.textFields?.first else {
                return
            }
            
            if self.isUpdate {
                self.checkConstellationAndUpdate(constellation: textField.text ?? "", indexPath: self.updateIndexPath)
            } else {
                self.checkConstellationAndDelete(constellation: textField.text ?? "", indexPath: self.deleteIndexPath)
            }
        }
        checkStarAlertController.addAction(okAction)
    }
    
    func checkConstellationAndDelete(constellation: String, indexPath: IndexPath) {
        let group = groupArray[indexPath.section]
        let deleteRecord = orderRecords.filter { $0.fields.className == group }[indexPath.row]
        
        if deleteRecord.fields.constellation == constellation {
            for (index, record) in orderRecords.enumerated() {
                if let id = record.id, record == deleteRecord {
                    NetworkController.shared.deleteOrder(id: id) { result in
                        switch result {
                        case .success(let content):
                            print(content)
                        case .failure(let error):
                            self.showWarnningAlert(title: "Warnning", message: "Delete fail:\(error)")
                            print("Delete fail:\(error)")
                        }
                    }
                    orderRecords.remove(at: index)
                    DispatchQueue.main.async {
                        self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                    }
                    break
                }
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            let(isFind, sectionIndex) = findEmptyGroup()
            if isFind {
                updateGroupArray()
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            }
        } else {
            showWarnningAlert(title: "Warnning", message: "星座錯誤")
        }
    }
    
    func checkConstellationAndUpdate(constellation: String, indexPath: IndexPath) {
        let group = groupArray[indexPath.section]
        let updateRecord = orderRecords.filter { $0.fields.className == group }[indexPath.row]
        
        if updateRecord.fields.constellation == constellation {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "\(DrinkTableViewController.self)") as? DrinkTableViewController,
                let orderID = updateRecord.id,
                let nav = navigationController {
                controller.orderID = orderID
                nav.pushViewController(controller, animated: true)
            }
        } else {
            showWarnningAlert(title: "Warnning", message: "星座錯誤")
        }
    }
    
    func showWarnningAlert(title: String, message: String) {
        let warnningController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        warnningController.addAction(okAction)
        present(warnningController, animated: true, completion: nil)
    }
    
    func updateGroupArray() {
        groupSet.removeAll()
        orderRecords.forEach { groupSet.insert($0.fields.className) }
        groupArray = groupSet.sorted()
    }
    
    func findEmptyGroup() -> (Bool, Int) {
        for (i, group) in groupArray.enumerated() {
            if orderRecords.filter({ $0.fields.className == group }).count == 0 {
                return (true, i)
            }
        }
        return (false, -1)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        groupArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orderRecords.filter { $0.fields.className == groupArray[section] }.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        
        view.backgroundColor = UIColor.clear
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: view.bounds.width - 10, height: 50))
        label.text = groupArray[section]
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 30)
        view.addSubview(label)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        
        view.backgroundColor = UIColor.clear
        let label = UILabel(frame: CGRect(x: 10, y: 5, width: view.bounds.width - 50, height: 30))
        
        let group = groupArray[section]
        let filtedRecords = orderRecords.filter { $0.fields.className == group }
        let sum = filtedRecords.reduce(0) { $0 + $1.fields.sum }
        label.text = "\(sum) 元"
        label.textColor = UIColor.systemBrown
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(label)
        
        return view
    }
    
    func getOrder(indexPath: IndexPath) -> OrderRecord {
        let group = groupArray[indexPath.section]
        let filtedRecords = orderRecords.filter { $0.fields.className == group }
        return filtedRecords[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ORDER_CELL_ID, for: indexPath) as? OrderTableViewCell else {
            return UITableViewCell()
        }

        let order = getOrder(indexPath: indexPath)
        
        cell.nameLabel.text = order.fields.name
        cell.drinkNameLabel.text = order.fields.drinkName
        var tempArray = [String]()
        tempArray.append(order.fields.temperture)
        if let ice = order.fields.ice {
            tempArray.append(ice)
        }
        if let sugar = order.fields.sugar {
            tempArray.append(sugar)
        }
        cell.tempertureLabel.text = tempArray.joined(separator: ", ")
        if let flavors = order.fields.flavor {
            cell.flavorLabel.text = flavors.joined(separator: ", ")
        } else {
            cell.flavorLabel.text = ""
        }
        let size = DrinkSize.large.rawValue == order.fields.size ? DrinkSize.large : DrinkSize.bottle
        cell.quantityLabel.text = size.getOrderName(quantity: order.fields.quantity)
        cell.priceLabel.text = "\(order.fields.sum) 元"

        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            isUpdate = false
            deleteIndexPath = indexPath
            
            present(checkStarAlertController, animated: true, completion: nil)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isUpdate = true
        updateIndexPath = indexPath
        present(checkStarAlertController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onShowMenu(_ sender: Any) {
        performSegue(withIdentifier: MENU_SEGUE_ID, sender: nil)
    }
    
    @IBAction func cancelStarPicker(_ sender: Any) {
        guard let textField = self.checkStarAlertController.textFields?.first else {
            return
        }
        
        textField.text = ""
        textField.resignFirstResponder()
    }
    
    @IBAction func doneStarPicker(_ sender: Any) {
        guard let textField = self.checkStarAlertController.textFields?.first else {
            return
        }
        
        textField.resignFirstResponder()
    }
    
    @IBSegueAction func updateOrder(_ coder: NSCoder, sender: Any?) -> DrinkTableViewController? {
        guard let controller = DrinkTableViewController(coder: coder),
              let indexPath = tableView.indexPathForSelectedRow else {
                  return nil
        }
        let order = getOrder(indexPath: indexPath)
        controller.orderID = order.id ?? ""
        
        return controller
    }
    
}

extension OrderTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
        guard let textField = self.checkStarAlertController.textFields?.first else {
            return
        }
        textField.text = Constellation.allCases[row].rawValue
    }
    
    
}
