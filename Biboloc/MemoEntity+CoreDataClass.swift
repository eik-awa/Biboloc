//
//  MemoEntity+CoreDataClass.swift
//  Biboloc
//

import Foundation
import CoreData

@objc(MemoEntity)
public class MemoEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var created_at: Date
    @NSManaged public var text: String
    @NSManaged public var favorite: Bool
    @NSManaged public var isInTrash: Bool
    @NSManaged public var tags: NSSet?

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: TagEntity)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: TagEntity)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
}
