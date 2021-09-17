//
//  Stroe.swift
//  Stroe
//
//  Created by 張又壬 on 2021/9/15.
//

import Foundation

struct Store: Decodable {
    let name: String
    let phone: [String]
    let address: String
}

protocol PhoneDelegate {
    func callPhoneNumber(phones: [String])
}
