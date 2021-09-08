//
//  DrinkData.swift
//  DrinkData
//
//  Created by 張又壬 on 2021/8/30.
//

import Foundation

struct Records: Codable {
    let records: [Record]
}

struct Record: Codable {
    let id: String
    let fields: DrinkField
}

struct DrinkField: Codable {
    let name: String
    let group: String
    let temperature: [String]
    let seasonLimited: String?
    let largePrice: Int
    let bottlePrice: Int?
    let constraints: [String]?
    let image: [ImageData]
    var smallThumb: URL? {
        image.first?.thumbnails.small.url
    }
    var largeThumb: URL? {
        image.first?.thumbnails.large.url
    }
    var realImage: URL? {
        image.first?.url
    }
}

struct ImageData: Codable {
    let width: Int
    let height: Int
    let url: URL
    let thumbnails: Thumbnails
}

struct Thumbnails: Codable {
    let small: Thumbnail
    let large: Thumbnail
    let full: Thumbnail
}

struct Thumbnail: Codable {
    let width: Int
    let height: Int
    let url: URL
}
