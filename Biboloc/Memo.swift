//
//  Memo.swift
//  Biboloc
//
//  Created by awa on 2023/07/21.
//

import Foundation.NSObject

class Memo: NSObject, Identifiable, NSCoding {
    
    public var id = UUID()
    var created_at: Date
    var text: String
    var tag: [Tag]
    var deleted: Bool = false
    
    init(_ created_at: Date, _ text: String, _ tag: [Tag], _ deleted: Bool) {
        self.created_at = created_at
        self.text = text
        self.tag = tag
        self.deleted = deleted
    }
    
    required init?(coder: NSCoder) {
        created_at = coder.decodeObject(forKey: "created_at") as? Date ?? Date()
        text = coder.decodeObject(forKey: "text") as! String
        tag = coder.decodeObject(forKey: "tag") as! [Tag]
        deleted = coder.decodeBool(forKey: "deleted")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(created_at, forKey: "created_at")
        coder.encode(text, forKey: "text")
        coder.encode(tag, forKey: "tag")
        coder.encode(deleted, forKey: "deleted")
    }
}
