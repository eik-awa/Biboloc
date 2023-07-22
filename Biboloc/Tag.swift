//
//  Tag.swift
//  Biboloc
//
//  Created by awa on 2023/07/21.
//

import Foundation

public struct Tag: Identifiable, Codable {
    public var id = UUID()
    var name: String
    var deleted: Bool = false
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
        case deleted = "deleted"
    }
}
