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
    var favorite: Bool = false
    
    init(created_at: Date, text: String, tag: [Tag], favorite: Bool) {
        self.created_at = created_at
        self.text = text
        self.tag = tag
        self.favorite = favorite
    }
    
    required init?(coder: NSCoder) {
        created_at = coder.decodeObject(forKey: "created_at") as? Date ?? Date()
        text = coder.decodeObject(forKey: "text") as! String
        tag = coder.decodeObject(forKey: "tag") as! [Tag]
        favorite = coder.decodeBool(forKey: "favorite")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(created_at, forKey: "created_at")
        coder.encode(text, forKey: "text")
        coder.encode(tag, forKey: "tag")
        coder.encode(favorite, forKey: "favorite")
    }
}
