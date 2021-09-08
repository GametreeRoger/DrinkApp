//
//  NetworkController.swift
//  NetworkController
//
//  Created by 張又壬 on 2021/8/31.
//

import Foundation
import UIKit

class NetworkController {
    static let shared = NetworkController()
    let API_KEY = "keyz3ayqkNkdvmnF5"
    let baseURL = URL(string: "https://api.airtable.com/v0/app0sXyPpAXvCMzL4/")!
    
    func fetchMenuItems(completion: @escaping (Result<[Record], Error>) -> Void) {
        let drinkTableUrl = baseURL.appendingPathComponent("DrinkTable")
        var urlRequest = URLRequest(url: drinkTableUrl, cachePolicy: .returnCacheDataElseLoad)
//        var urlRequest = URLRequest(url: drinkTableUrl)
        urlRequest.setValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: urlRequest) { data, response, resError in
            if let data = data,
               let content = String(data: data, encoding: .utf8),
               let response = response as? HTTPURLResponse,
               response.statusCode == 200,
               resError == nil {
                do {
//                    print("data: \(content)")
                    let decoder = JSONDecoder()
                    let recordData = try decoder.decode(Records.self, from: data)
                    completion(.success(recordData.records))
                } catch {
                    print("fetchMenuItems, Parse JSON failed, error: \(error)")
                    completion(.failure(error))
                }
            } else if let error = resError {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchOrders(completion: @escaping (Result<[OrderRecord], Error>) -> Void ) {
        let orderUrl = baseURL.appendingPathComponent("DrinkOrder")
        var urlRequest = URLRequest(url: orderUrl)
        urlRequest.setValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: urlRequest) { data, response, resError in
            if let data = data,
               let content = String(data: data, encoding: .utf8),
               let response = response as? HTTPURLResponse,
               response.statusCode == 200,
               resError == nil {
                do {
                    print("fetchOrders: \(content)")
                    let decoder = JSONDecoder()
                    let orderRecordData = try decoder.decode(OrderRecords.self, from: data)
                    completion(.success(orderRecordData.records))
                } catch {
                    print("fetchOrders, parse JSON failed, error: \(error)")
                    completion(.failure(error))
                }
            } else if let error = resError {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchImage(imageUrl: URL, completion: @escaping (UIImage?) -> Void) {
        let imageRequest = URLRequest(url: imageUrl, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        URLSession.shared.dataTask(with: imageRequest) { data, response, resError in
            if let data = data,
               let image = UIImage(data: data),
               let response = response as? HTTPURLResponse,
               response.statusCode == 200,
               resError == nil {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    func createOrder(order: OrderRecords, completion: @escaping (Result<String, Error>) -> Void) {
        let orderUrl = baseURL.appendingPathComponent("DrinkOrder")
        var request = URLRequest(url: orderUrl)
        request.setValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(order)
            URLSession.shared.dataTask(with: request) { data, response, resError in
                if let data = data,
                   let content = String(data: data, encoding: .utf8) {
                    completion(.success(content))
                } else if let resError = resError {
                    completion(.failure(resError))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    func updateOrder(order: OrderRecords, completion: @escaping (Result<String, Error>) -> Void) {
        let orderUrl = baseURL.appendingPathComponent("DrinkOrder")
        var request = URLRequest(url: orderUrl)
        request.setValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(order)
            URLSession.shared.dataTask(with: request) { data, response, resError in
                if let data = data,
                   let content = String(data: data, encoding: .utf8) {
                    completion(.success(content))
                } else if let resError = resError {
                    completion(.failure(resError))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteOrder(id: String, completion: @escaping (Result<String, Error>) -> Void) {
        let orderUrl = baseURL.appendingPathComponent("DrinkOrder").appending("records[]", value: id)
        var request = URLRequest(url: orderUrl)
        request.setValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, resError in
            if let data = data,
               let content = String(data: data, encoding: .utf8) {
                completion(.success(content))
            } else if let resError = resError {
                completion(.failure(resError))
            }
        }.resume()
    }
}


extension URL {

    func appending(_ queryItem: String, value: String?) -> URL {

        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // Create query item
        let queryItem = URLQueryItem(name: queryItem, value: value)

        // Append the new query item in the existing query items array
        queryItems.append(queryItem)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        return urlComponents.url!
    }
}
