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
    var deleted: Bool = false
    
    init(name: String, _ deleted: Bool) {
        self.name = name
        self.deleted = deleted
    }
    
    required init?(coder: NSCoder) {
        name = coder.decodeObject(forKey: "name") as! String
        deleted = coder.decodeBool(forKey: "deleted")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(deleted, forKey: "deleted")
    }
}

