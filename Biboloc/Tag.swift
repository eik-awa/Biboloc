//
//  Tag.swift
//  Biboloc
//
//  Created by awa on 2023/07/21.
//

import Foundation.NSObject

class Tag: NSObject, Identifiable, NSCoding {
    
    public var id = UUID()
    let name: String
    var used_at: Date
    var deleted: Bool = false
    
    init(name: String, used_at: Date, deleted: Bool) {
        self.name = name
        self.used_at = used_at
        self.deleted = deleted
    }
    
    required init?(coder: NSCoder) {
        name = coder.decodeObject(forKey: "name") as! String
        used_at = coder.decodeObject(forKey: "used_at") as? Date ?? Date()
        deleted = coder.decodeBool(forKey: "deleted")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(used_at, forKey: "used_at")
        coder.encode(deleted, forKey: "deleted")
    }
}

