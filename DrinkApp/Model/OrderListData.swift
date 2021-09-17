//
//  OrderListData.swift
//  OrderListData
//
//  Created by 張又壬 on 2021/9/13.
//

import Foundation

struct OrderListField: Hashable {
    let drinkName: String
    let temperture: String
    let ice: String?
    let sugar: String?
    let flavor: [String]?
    let size: String
    var quantity: Int
    var sum: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(drinkName)
        hasher.combine(temperture)
        if let ice = ice {
            hasher.combine(ice)
        }
        if let sugar = sugar {
            hasher.combine(sugar)
        }
        if let flavor = flavor {
            hasher.combine(flavor.sorted())
        }
        hasher.combine(size)
    }
}

extension OrderListField: Equatable {
    static func ==(lhs: OrderListField, rhs: OrderListField) -> Bool {
        return lhs.drinkName == rhs.drinkName && lhs.temperture == rhs.temperture && lhs.ice == rhs.ice && lhs.sugar == rhs.sugar && lhs.flavor?.sorted() == rhs.flavor?.sorted() && lhs.size == rhs.size
    }
}
