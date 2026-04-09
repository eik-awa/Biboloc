//
//  Memo.swift
//  Biboloc
//
//  Created by awa on 2023/07/21.
//

import Foundation.NSObject

class Memo: NSObject, Identifiable, NSSecureCoding {

    static var supportsSecureCoding: Bool = true

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
        if let uuidString = coder.decodeObject(of: NSString.self, forKey: "id") as String? {
            id = UUID(uuidString: uuidString) ?? UUID()
        }
        created_at = coder.decodeObject(of: NSDate.self, forKey: "created_at") as Date? ?? Date()
        text = coder.decodeObject(of: NSString.self, forKey: "text") as String? ?? ""
        tag = coder.decodeObject(of: [NSArray.self, Tag.self], forKey: "tag") as? [Tag] ?? []
        favorite = coder.decodeBool(forKey: "favorite")
    }

    func encode(with coder: NSCoder) {
        coder.encode(id.uuidString as NSString, forKey: "id")
        coder.encode(created_at as NSDate, forKey: "created_at")
        coder.encode(text as NSString, forKey: "text")
        coder.encode(tag as NSArray, forKey: "tag")
        coder.encode(favorite, forKey: "favorite")
    }
}
