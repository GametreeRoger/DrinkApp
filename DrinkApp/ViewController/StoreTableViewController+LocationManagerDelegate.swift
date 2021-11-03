//
//  StoreTableViewController+LocationManagerDelegate.swift
//  DrinkApp
//
//  Created by 張又壬 on 2021/11/3.
//

import Foundation
import CoreLocation

extension StoreTableViewController: CLLocationManagerDelegate {
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    func getLocation() {
        for (i, store) in stores.enumerated() {
//            print(store.store.address)
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(store.store.address) { placemarks, error in
                if error != nil {
                    print("geocodeAddressString Error:", error!)
                    return
                }
                guard let placemarks = placemarks,
                      placemarks.count > 0 else {
                          return
                      }
                for placemark in placemarks {
//                    print("\(i): \(placemark.location?.coordinate.latitude ?? 0.0), \(placemark.location?.coordinate.longitude ?? 0.0)")
                    if let location = placemark.location {
                        self.stores[i].location = location
                    }
                }
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate protocol
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("My locate: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            for (i, store) in stores.enumerated() {
                let storelocation = store.location
                let dis = storelocation?.distance(from: location)
                stores[i].distance = dis
//                print("distance:\(dis!)")
            }
            
            stores.sort { $0.distance! < $1.distance! }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("fail: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
}
