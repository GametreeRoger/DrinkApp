//
//  OrderData.swift
//  OrderData
//
//  Created by 張又壬 on 2021/9/2.
//

import Foundation

struct OrderRecords: Codable {
    let records: [OrderRecord]
}

struct OrderRecord: Codable {
    let id: String?
    let fields: OrderField
    init(fields: OrderField, id: String? = nil) {
        self.fields = fields
        self.id = id
    }
}

extension OrderRecord: Equatable {
    static func ==(lhs: OrderRecord, rhs: OrderRecord) -> Bool {
        return lhs.id == rhs.id
    }
}

struct OrderField: Codable {
    let name: String
    let constellation: String
    let className: String
    let drinkName: String
    let temperture: String
    let ice: String?
    let sugar: String?
    let flavor: [String]?
    let size: String
    let quantity: Int
    let sum: Int
}

extension OrderField: Equatable {
    static func ==(lhs: OrderField, rhs: OrderField) -> Bool {
        return lhs.name == rhs.name && lhs.constellation == rhs.constellation && lhs.className == rhs.className && lhs.drinkName == rhs.drinkName && lhs.temperture == rhs.temperture && lhs.ice == rhs.ice && lhs.sugar == rhs.sugar && lhs.flavor == rhs.flavor && lhs.size == rhs.size && lhs.sum == rhs.sum
    }
}

enum Flavor: String, CaseIterable{
    case coconut = "椰果"
    case xiancaoJelly = "仙草凍"
    case bigPearl = "波霸"
    case pearl = "珍珠"
    case pearlMix = "混珠"
    case pearlDouble = "雙Q果"
    case honey = "蜂蜜"
    case yakult = "養樂多"
    case greenTeaJelly = "綠茶凍"
    case grape = "葡萄波波"
    case cheese = "芝芝"
    case pudding = "布蕾"
    case iceCream = "冰淇淋"
    
    var price: Int {
        switch self {
        case .coconut, .xiancaoJelly:
            return 5
        case .bigPearl, .pearl, .pearlMix, .pearlDouble, .honey, .yakult, .greenTeaJelly:
            return 10
        case .grape:
            return 15
        case .cheese, .pudding, .iceCream:
            return 20
        }
    }
    
    static func getFlavor(tag: Int) -> Self {
        switch tag {
        case 0: return .coconut
        case 1: return .xiancaoJelly
        case 2: return .bigPearl
        case 3: return .pearl
        case 4: return .pearlMix
        case 5: return .pearlDouble
        case 6: return .honey
        case 7: return .yakult
        case 8: return .greenTeaJelly
        case 9: return .grape
        case 10: return .cheese
        case 11: return .pudding
        case 12: return .iceCream
        default: return .coconut
        }
    }
}

enum Temperture: String {
    case cold = "冷"
    case hot = "熱"
    case smoothie = "冰沙"
    case crushedSmoothie = "碎冰沙"
}

enum DrinkConstraints: String {
    case sugarFixed = "甜度固定"
    case iceFixed = "冰量固定"
}

enum DrinkSize: String {
    case large = "大"
    case bottle = "瓶"
    
    func getOrderName(quantity: Int) -> String {
        switch self {
        case .large:
            return "大杯 * \(quantity)"
        case .bottle:
            return "瓶 * \(quantity)"
        }
    }
}

enum DrinkIce: String {
    case no = "去冰"
    case micro = "微冰"
    case less = "少冰"
    case normal = "正常冰"
    
    static func getDrinkIce(tag: Int) -> Self {
        switch tag {
        case 0: return .no
        case 1: return .micro
        case 2: return .less
        case 3: return .normal
        default: return .no
        }
    }
}

enum DrinkSugar: String {
    case no = "無糖"
    case oneTenth = "一分"
    case oneThird = "三分"
    case half = "半糖"
    case eightyPercent = "八分"
    case normal = "正常"
    
    static func getDrinkSugar(tag: Int) -> DrinkSugar {
        switch tag {
        case 0: return .no
        case 1: return .oneTenth
        case 2: return .oneThird
        case 3: return .half
        case 4: return .eightyPercent
        case 5: return .normal
        default: return .no
        }
    }
}

enum Constellation: String, CaseIterable {
    case Aries = "牡羊座"
    case Taurus = "金牛座"
    case Gemini = "雙子座"
    case Cancer = "巨蟹座"
    case Leo = "獅子座"
    case Virgo = "處女座"
    case Libra = "天秤座"
    case Scorpio = "天蠍座"
    case Sagittarius = "射手座"
    case Capricorn = "摩羯座"
    case Aquarius = "水瓶座"
    case Pisces = "雙魚座"
}
