//
//  TagEntity+CoreDataClass.swift
//  Biboloc
//

import Foundation
import CoreData

@objc(TagEntity)
public class TagEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var used_at: Date
    @NSManaged public var memos: NSSet?

    @objc(addMemosObject:)
    @NSManaged public func addToMemos(_ value: MemoEntity)

    @objc(removeMemosObject:)
    @NSManaged public func removeFromMemos(_ value: MemoEntity)

    @objc(addMemos:)
    @NSManaged public func addToMemos(_ values: NSSet)

    @objc(removeMemos:)
    @NSManaged public func removeFromMemos(_ values: NSSet)
}
