//
//  deleteOrder.swift
//  deleteOrder
//
//  Created by 張又壬 on 2021/9/4.
//

import Foundation

struct DeleteRecords {
    let records: [DeleteRecord]
}

struct DeleteRecord {
    let id: String
    let deleted: Bool
}
