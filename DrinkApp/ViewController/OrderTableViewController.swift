//
//  OrderTableViewController.swift
//  OrderTableViewController
//
//  Created by 張又壬 on 2021/9/4.
//

import UIKit

class OrderTableViewController: UITableViewController {

    let ORDER_CELL_ID = "OrderCellID"
    let NO_ORDER_CELL_ID = "NoOrderCellID"
    let MENU_SEGUE_ID = "showMenu"
    
    var orderRecords = [OrderRecord]()
    var groupSet = Set<String>()
    var groupArray = [String]()
    let checkStarAlertController = UIAlertController(title: "密碼", message: "認證密碼", preferredStyle: .alert)
    var deleteIndexPath = IndexPath()
    var updateIndexPath = IndexPath()
    var isUpdate = true
    var loadingController: LoadingViewController?
    var isNoOrder: Bool = true
    
    @IBOutlet var starPickerView: UIPickerView!
    
    @IBOutlet var starPickerToolbar: UIToolbar!
    
    @IBOutlet weak var toolbarTitleButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initCheckPasswordAlert()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let loadingController = storyboard?.instantiateViewController(withIdentifier: "\(LoadingViewController.self)") as? LoadingViewController {
            self.loadingController = loadingController
        }
        updateOrder()
    }
    
    func loading(enable: Bool) {
        if let loadingController = loadingController {
            if enable {
                present(loadingController, animated: true, completion: nil)
            } else {
                loadingController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func updateOrder() {
        loading(enable: true)
        
        NetworkController.shared.fetchOrders { result in
            DispatchQueue.main.async {
                self.loading(enable: false)
            }
            switch result {
            case .success(let orderRecords):
                self.orderRecords = orderRecords
                self.isNoOrder = orderRecords.isEmpty ? true : false
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
                    
                    DispatchQueue.main.async {
                        self.orderRecords.remove(at: index)
                        
                        if self.orderRecords.isEmpty {
                            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                self.isNoOrder = true
                                print("No order reload.......")
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                        
                        let(isFind, sectionIndex) = self.findEmptyGroup()
                        if isFind {
                            self.updateGroupArray()
                            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
                        } else {
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                            self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                        }
                    }
                    break
                }
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
        if isNoOrder {
            return 1
        } else {
            return groupArray.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isNoOrder {
            return 1
        } else {
            return orderRecords.filter { $0.fields.className == groupArray[section] }.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isNoOrder {
            return 0
        } else {
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isNoOrder {
            return 0
        } else {
            return 40
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isNoOrder {
            return 400
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isNoOrder {
            return nil
        } else {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            
            view.backgroundColor = UIColor.clear
            let label = UILabel(frame: CGRect(x: 10, y: 0, width: view.bounds.width - 10, height: 50))
            label.text = groupArray[section]
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 30)
            view.addSubview(label)
            
            return view
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isNoOrder {
            return nil
        } else {
            let footerView = UIView()
            footerView.backgroundColor = .clear
            let whiteCornerView = UIView()
            whiteCornerView.backgroundColor = .systemBrown
            whiteCornerView.layer.cornerRadius = 10
            footerView.addSubview(whiteCornerView)
            whiteCornerView.translatesAutoresizingMaskIntoConstraints = false
            whiteCornerView.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 5).isActive = true
            whiteCornerView.bottomAnchor.constraint(equalTo: footerView.bottomAnchor).isActive = true
            whiteCornerView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor).isActive = true
            whiteCornerView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor).isActive = true
            let label = UILabel()
            let group = groupArray[section]
            let filtedRecords = orderRecords.filter { $0.fields.className == group }
            let sum = filtedRecords.reduce(0) { $0 + $1.fields.sum }
            label.text = "\(sum) 元"
            label.textColor = .white
            label.textAlignment = .right
            label.font = UIFont.boldSystemFont(ofSize: 20)
            whiteCornerView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.centerYAnchor.constraint(equalTo: whiteCornerView.centerYAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: whiteCornerView.trailingAnchor, constant: -10).isActive = true
            let listButton = UIButton()
            listButton.addAction(UIAction(handler: { action in
                if let orderlistController = self.storyboard?.instantiateViewController(withIdentifier: "\(OrderListTableViewController.self)") as? OrderListTableViewController,
                   let nav = self.navigationController {
                    orderlistController.orderRecords = filtedRecords
                    nav.pushViewController(orderlistController, animated: true)
                }
            }), for: .primaryActionTriggered)
            
            listButton.setTitle("訂單", for: .normal)
            listButton.setImage(UIImage(systemName: "list.bullet.rectangle"), for: .normal)
            listButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            listButton.setTitleColor(.white, for: .normal)
            listButton.tintColor = .white
//            if var config = listButton.configuration {
//                config.title = "訂單"
//                config.image = UIImage(systemName: "list.bullet.rectangle")
//                config.imagePadding = 5.0
//                config.baseForegroundColor = .white
//                if var attTitle = config.attributedTitle {
//                    attTitle.font = UIFont.boldSystemFont(ofSize: 15)
//                    config.attributedTitle = attTitle
//                }
//                listButton.configuration = config
//            }
            whiteCornerView.addSubview(listButton)
            listButton.translatesAutoresizingMaskIntoConstraints = false
            listButton.centerYAnchor.constraint(equalTo: whiteCornerView.centerYAnchor).isActive = true
            listButton.leadingAnchor.constraint(equalTo: whiteCornerView.leadingAnchor, constant: 10).isActive = true
            return footerView
        }
    }
    
    func getOrder(indexPath: IndexPath) -> OrderRecord {
        let group = groupArray[indexPath.section]
        let filtedRecords = orderRecords.filter { $0.fields.className == group }
        return filtedRecords[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isNoOrder {
            return tableView.dequeueReusableCell(withIdentifier: NO_ORDER_CELL_ID, for: indexPath)
        }
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
            cell.flavorLabel.text = " "
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
