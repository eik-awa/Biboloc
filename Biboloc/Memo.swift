//
//  Memo.swift
//  Biboloc
//
//  Created by awa on 2023/07/21.
//

import Foundation

public struct Memo: Identifiable, Codable {
    public var id = UUID()
    var created_at: Date
    var text: String
    var tag: [Tag]
    var deleted: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case created_at = "created_at"
        case text
        case tag
        case deleted = "deleted"
    }
}
