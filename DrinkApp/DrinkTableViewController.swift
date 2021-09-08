//
//  DrinkTableViewController.swift
//  DrinkTableViewController
//
//  Created by 張又壬 on 2021/8/30.
//

import UIKit

class DrinkTableViewController: UITableViewController {

    let DRINK_CELL_ID = "DrinkCell"
    var records = [Record]()
    var groupSet = Set<String>()
    var groupArray = [String]()
    var orderID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkController.shared.fetchMenuItems { result in
            switch result {
            case .success(let records):
                self.records = records
                self.records.forEach { self.groupSet.insert($0.fields.group) }
                self.groupArray = self.groupSet.sorted()
//                print("group set count: \(self.groupSet.count), group array count: \(self.groupArray.count)")
//                for group in self.groupArray {
//                    print("group:\(group), count:\(self.records.filter { $0.fields.group == group }.count)")
//                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Fetch Menu failed: \(error)")
            }
        }
    }
    
    func getRecord(indexPath: IndexPath) -> Record {
        let group = groupArray[indexPath.section]
        let filteredRecords = records.filter{ $0.fields.group == group }
        return filteredRecords[indexPath.row]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        groupArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        records.filter { $0.fields.group == groupArray[section] }.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        
        view.backgroundColor = UIColor.clear
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: view.bounds.width - 10, height: 50))
        label.text = groupArray[section]
        label.textColor = UIColor.white
        print("section:\(section), group:\(groupArray[section])")
        label.font = UIFont.boldSystemFont(ofSize: 30)
        
        view.addSubview(label)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DRINK_CELL_ID, for: indexPath) as? DrinkTableViewCell else {
            return UITableViewCell()
        }

        let record = getRecord(indexPath: indexPath)
        
        let id = record.id

        cell.NameLabel.text = record.fields.name
        cell.TempertureLabel.text = record.fields.temperature.joined(separator: "/")
        if let seasonLimited = record.fields.seasonLimited {
            cell.MonthLimitedLabel.text = "\(seasonLimited) 月"
        } else {
            cell.MonthLimitedLabel.text = ""
        }
        cell.DrinkImageView.image = UIImage(named: "drink_default")
        
        if let imageUrl = record.fields.largeThumb {
            NetworkController.shared.fetchImage(imageUrl: imageUrl) { image in
                if let image = image,
                   id == record.id {
                    DispatchQueue.main.async {
                        cell.DrinkImageView.image = image
                    }
                }
            }
        }
        return cell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return false
        }
        let record = getRecord(indexPath: indexPath)
        if let limited = record.fields.seasonLimited {
            var monthAy = Array<Int>()
            let months = limited.split(separator: "-").map { Int($0) ?? 0 }
            if months[0] > months[1] {
                for i in months[0]...12 {
                    monthAy.append(i)
                }
                for i in 1...months[1] {
                    monthAy.append(i)
                }
            } else {
                monthAy = Array(months[0]...months[1])
            }
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.month], from: Date())
            if let nowMonth = components.month,
               monthAy.contains(nowMonth) {
                return true
            } else {
                let alertController = UIAlertController(title: "季節限定", message: "暫不提供", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(alertAction)
                present(alertController, animated: true, completion: nil)
                return false
            }
        }
        
        return true
    }

    @IBSegueAction func showDetail(_ coder: NSCoder, sender: Any?) -> DrinkDetailTableViewController? {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return nil
        }
        
        let record = getRecord(indexPath: indexPath)
        if orderID.isEmpty {
            return DrinkDetailTableViewController(coder: coder, field: record.fields)
        } else {
            return DrinkDetailTableViewController(coder: coder, field: record.fields, orderID: orderID)
        }
    }
    
}
