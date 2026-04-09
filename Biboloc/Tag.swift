//
//  Tag.swift
//  Biboloc
//
//  Created by awa on 2023/07/21.
//

import Foundation.NSObject

class Tag: NSObject, Identifiable, NSSecureCoding {

    static var supportsSecureCoding: Bool = true

    public var id = UUID()
    let name: String
    var used_at: Date

    init(name: String, used_at: Date) {
        self.name = name
        self.used_at = used_at
    }

    required init?(coder: NSCoder) {
        if let uuidString = coder.decodeObject(of: NSString.self, forKey: "id") as String? {
            id = UUID(uuidString: uuidString) ?? UUID()
        }
        name = coder.decodeObject(of: NSString.self, forKey: "name") as String? ?? ""
        used_at = coder.decodeObject(of: NSDate.self, forKey: "used_at") as Date? ?? Date()
    }

    func encode(with coder: NSCoder) {
        coder.encode(id.uuidString as NSString, forKey: "id")
        coder.encode(name as NSString, forKey: "name")
        coder.encode(used_at as NSDate, forKey: "used_at")
    }
}
