//
//  StoreTableViewController.swift
//  StoreTableViewController
//
//  Created by 張又壬 on 2021/9/15.
//

import UIKit
import CoreLocation

class StoreTableViewController: UITableViewController {

    var stores = [StoreLocation]()
    let locationManager = CLLocationManager()
    var phoneDelegate: PhoneDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuthorization()
        readStoreList()
        getLocation()
    }
    
    func readStoreList() {
        if let url = Bundle.main.url(forResource: "Store", withExtension: "plist"),
           let data = try? Data(contentsOf: url) {
            do {
                let storesdata = try PropertyListDecoder().decode([Store].self, from: data)
                for data in storesdata {
                    stores.append(StoreLocation(store: data))
                }
            } catch {
                print("Parse Plist failed:\(error)")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stores.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let titleLabel = UILabel()
        headerView.addSubview(titleLabel)
        titleLabel.text = "點選要打電話的店舖"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = .systemBrown
        titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10).isActive = true
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(StoreTableViewCell.self)", for: indexPath) as? StoreTableViewCell else {
            return UITableViewCell()
        }

        let index = indexPath.row
        let store = stores[index]
        cell.nameLabel.text = store.store.name
        cell.addressLabel.text = store.store.address
        cell.phoneLabel.text = store.store.phone.joined(separator: "/")
        cell.distanceLabel.isHidden = locationManager.authorizationStatus != .authorizedWhenInUse
        if let meters = store.distance, locationManager.authorizationStatus == .authorizedWhenInUse {
            cell.distanceLabel.text = String(format: "距離 %.0f 公尺", meters)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true)
        
        if let phoneDelegate = phoneDelegate {
            let index = indexPath.row
            let store = stores[index]
            phoneDelegate.callPhoneNumber(phones: store.store.phone)
        }
    }
}
