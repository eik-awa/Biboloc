//
//  BibolocApp.swift
//  Biboloc
//
//  Created by awa on 2023/07/21.
//

import SwiftUI
import Foundation
import CoreData
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if canImport(GoogleMobileAds)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        #endif
        return true
    }
}

class LockManager: ObservableObject {
    @Published var isUnlocked: Bool = false
}

@main
struct BibolocApp: App {
    @StateObject var database = Database()// 画面上部の余白
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var lockManager = LockManager()
    @Environment(\.scenePhase) var scenePhase
    @State private var backgroundDate: Date?
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // ロック画面
                if !lockManager.isUnlocked && KeychainHelper.hasPasscode() {
                    LockScreenView(
                        isUnlocked: $lockManager.isUnlocked,
                        passcodeLength: KeychainHelper.loadPasscode()?.count ?? 4
                    )
                    .transition(.opacity)
                    .zIndex(1)
                } else {
                    ContentView(database: database)
                        .onAppear() {
                            if !KeychainHelper.hasPasscode() {
                                lockManager.isUnlocked = true
                            }
                        }
                        .edgesIgnoringSafeArea(.all)
                }
                
            }
            .animation(.easeInOut, value: lockManager.isUnlocked)
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .background:
                    backgroundDate = Date()

                case .active:
                    if let date = backgroundDate {
                        if Date().timeIntervalSince(date) > 5 {
                            lockManager.isUnlocked = false
                        }
                    }
                    backgroundDate = nil

                default:
                    break
                }
            }
        }
    }
}

class Database: ObservableObject {
    @Published var TagList: Array<Tag> = []
    @Published var DeletedMemoList: Array<Memo> = []
    @Published var MemoList: Array<Memo> = []

    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext { container.viewContext }

    init() {
        container = NSPersistentContainer(name: "MemoModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data の読み込みに失敗しました: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        migrateFromUserDefaultsIfNeeded()
        fetchAll()
    }

    // MARK: - UserDefaults からのマイグレーション

    private func migrateFromUserDefaultsIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: "coreDataMigrated") else { return }

        let memos = legacyLoadMemos()
        let tags = legacyLoadTags()
        let deletedMemos = legacyLoadDeletedMemos()

        if memos.isEmpty && tags.isEmpty && deletedMemos.isEmpty {
            // 初回起動 - デフォルトデータを挿入
            let defaultTag = Tag(name: "備忘録", used_at: Date())
            let defaultMemo = Memo(
                created_at: Date(),
                text: AppConstants.HOW_TO_USE,
                tag: [defaultTag],
                favorite: false
            )
            let tagEntity = insertTagEntity(from: defaultTag)
            insertMemoEntity(from: defaultMemo, isInTrash: false, tagEntities: [tagEntity])
        } else {
            // 既存データをマイグレーション
            var tagEntityMap: [UUID: TagEntity] = [:]
            for tag in tags {
                let entity = insertTagEntity(from: tag)
                tagEntityMap[tag.id] = entity
            }
            for memo in memos {
                var tagEntities: [TagEntity] = []
                for tag in memo.tag {
                    if let entity = tagEntityMap[tag.id] {
                        tagEntities.append(entity)
                    } else {
                        // TagList にないタグも保持する
                        let entity = insertTagEntity(from: tag)
                        tagEntityMap[tag.id] = entity
                        tagEntities.append(entity)
                    }
                }
                insertMemoEntity(from: memo, isInTrash: false, tagEntities: tagEntities)
            }
            for memo in deletedMemos {
                let tagEntities = memo.tag.compactMap { tagEntityMap[$0.id] }
                insertMemoEntity(from: memo, isInTrash: true, tagEntities: tagEntities)
            }
        }

        saveContext()
        UserDefaults.standard.set(true, forKey: "coreDataMigrated")
    }

    // MARK: - Fetch

    private func fetchAll() {
        MemoList = fetchMemos(inTrash: false)
        DeletedMemoList = fetchMemos(inTrash: true)
        TagList = fetchTags()
        exportToJSON()
    }

    private func fetchMemos(inTrash: Bool) -> [Memo] {
        let request = NSFetchRequest<MemoEntity>(entityName: "MemoEntity")
        request.predicate = NSPredicate(format: "isInTrash == %@", NSNumber(value: inTrash))
        request.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: false)]
        do {
            return try context.fetch(request).map { memoFromEntity($0) }
        } catch {
            return []
        }
    }

    private func fetchTags() -> [Tag] {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "used_at", ascending: false)]
        do {
            return try context.fetch(request).map { tagFromEntity($0) }
        } catch {
            return []
        }
    }

    // MARK: - Memo CRUD

    func createMemo(memo: Memo) {
        var tagEntities: [TagEntity] = []
        for tag in memo.tag {
            if let existing = fetchTagEntity(id: tag.id) {
                tagEntities.append(existing)
            } else {
                tagEntities.append(insertTagEntity(from: tag))
            }
        }
        insertMemoEntity(from: memo, isInTrash: false, tagEntities: tagEntities)
        saveContext()
        MemoList = fetchMemos(inTrash: false)
        exportToJSON()
    }

    func updateMemo() {
        for memo in MemoList {
            updateMemoEntity(from: memo)
        }
        saveContext()
        MemoList = fetchMemos(inTrash: false)
        exportToJSON()
    }

    func updateMemo(memo: Memo, memoData: Memo) {
        updateMemoEntity(from: memo)
        saveContext()
        MemoList = fetchMemos(inTrash: false)
        exportToJSON()
    }

    func deleteMemo(memo: Memo) {
        if let entity = fetchMemoEntity(id: memo.id) {
            entity.isInTrash = true
            saveContext()
        }
        MemoList = fetchMemos(inTrash: false)
        DeletedMemoList = fetchMemos(inTrash: true)
        exportToJSON()
    }

    func restoreMemo(memo: Memo) {
        if let entity = fetchMemoEntity(id: memo.id) {
            entity.isInTrash = false
            saveContext()
        }
        MemoList = fetchMemos(inTrash: false)
        DeletedMemoList = fetchMemos(inTrash: true)
        exportToJSON()
    }

    func permanentlyDeleteMemo(memo: Memo) {
        if let entity = fetchMemoEntity(id: memo.id) {
            context.delete(entity)
            saveContext()
        }
        DeletedMemoList = fetchMemos(inTrash: true)
        exportToJSON()
    }

    func permanentlyDeleteAllMemos() {
        let request = NSFetchRequest<MemoEntity>(entityName: "MemoEntity")
        request.predicate = NSPredicate(format: "isInTrash == YES")
        if let entities = try? context.fetch(request) {
            entities.forEach { context.delete($0) }
            saveContext()
        }
        DeletedMemoList = []
        exportToJSON()
    }

    // MARK: - Tag CRUD

    func createTag(tag: Tag) {
        if fetchTagEntity(id: tag.id) == nil {
            insertTagEntity(from: tag)
            saveContext()
        }
        TagList = fetchTags()
        exportToJSON()
    }

    func updateTag() {
        for tag in TagList {
            updateTagEntity(from: tag)
        }
        saveContext()
        TagList = fetchTags()
        exportToJSON()
    }

    func deleteTag(tag: Tag) {
        if let entity = fetchTagEntity(id: tag.id) {
            context.delete(entity)
            saveContext()
        }
        TagList = fetchTags()
        exportToJSON()
    }

    // MARK: - Core Data エンティティ操作

    @discardableResult
    private func insertMemoEntity(from memo: Memo, isInTrash: Bool, tagEntities: [TagEntity]) -> MemoEntity {
        let entity = MemoEntity(context: context)
        entity.id = memo.id
        entity.created_at = memo.created_at
        entity.text = memo.text
        entity.favorite = memo.favorite
        entity.isInTrash = isInTrash
        tagEntities.forEach { entity.addToTags($0) }
        return entity
    }

    private func updateMemoEntity(from memo: Memo) {
        guard let entity = fetchMemoEntity(id: memo.id) else { return }
        entity.created_at = memo.created_at
        entity.text = memo.text
        entity.favorite = memo.favorite
        let tagEntities = memo.tag.compactMap { fetchTagEntity(id: $0.id) }
        entity.tags = NSSet(array: tagEntities)
    }

    @discardableResult
    private func insertTagEntity(from tag: Tag) -> TagEntity {
        let entity = TagEntity(context: context)
        entity.id = tag.id
        entity.name = tag.name
        entity.used_at = tag.used_at
        return entity
    }

    private func updateTagEntity(from tag: Tag) {
        guard let entity = fetchTagEntity(id: tag.id) else { return }
        entity.used_at = tag.used_at
    }

    private func fetchMemoEntity(id: UUID) -> MemoEntity? {
        let request = NSFetchRequest<MemoEntity>(entityName: "MemoEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    private func fetchTagEntity(id: UUID) -> TagEntity? {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    // MARK: - ビューモデル変換

    private func memoFromEntity(_ entity: MemoEntity) -> Memo {
        let tags = (entity.tags?.allObjects as? [TagEntity] ?? []).map { tagFromEntity($0) }
        let memo = Memo(created_at: entity.created_at, text: entity.text, tag: tags, favorite: entity.favorite)
        memo.id = entity.id
        return memo
    }

    private func tagFromEntity(_ entity: TagEntity) -> Tag {
        let tag = Tag(name: entity.name, used_at: entity.used_at)
        tag.id = entity.id
        return tag
    }

    // MARK: - Core Data 保存

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Core Data 保存エラー: \(error)")
        }
    }

    // MARK: - JSON エクスポート（Files アプリから参照可能）

    func exportToJSON() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        func memoDict(_ memo: Memo) -> [String: Any] {
            [
                "id": memo.id.uuidString,
                "created_at": formatter.string(from: memo.created_at),
                "text": memo.text,
                "favorite": memo.favorite,
                "tags": memo.tag.map { $0.name }
            ]
        }

        let json: [String: Any] = [
            "exported_at": formatter.string(from: Date()),
            "memos": MemoList.map { memoDict($0) },
            "trash": DeletedMemoList.map { memoDict($0) },
            "tags": TagList.map { ["id": $0.id.uuidString, "name": $0.name, "used_at": formatter.string(from: $0.used_at)] }
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]) else { return }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("biboloc_memos.json")
        try? data.write(to: url, options: .atomic)
    }

    // MARK: - レガシー UserDefaults 読み込み（マイグレーション専用）

    private func legacyLoadMemos() -> [Memo] {
        guard let data = UserDefaults.standard.data(forKey: "MemoData"),
              let array = try? NSKeyedUnarchiver.unarchivedObject(
                ofClasses: [NSArray.self, Memo.self, Tag.self, NSString.self, NSDate.self, NSUUID.self, NSNumber.self],
                from: data) as? [Memo]
        else { return [] }
        return array
    }

    private func legacyLoadDeletedMemos() -> [Memo] {
        guard let data = UserDefaults.standard.data(forKey: "DeletedMemoData"),
              let array = try? NSKeyedUnarchiver.unarchivedObject(
                ofClasses: [NSArray.self, Memo.self, Tag.self, NSString.self, NSDate.self, NSUUID.self, NSNumber.self],
                from: data) as? [Memo]
        else { return [] }
        return array
    }

    private func legacyLoadTags() -> [Tag] {
        guard let data = UserDefaults.standard.data(forKey: "TagData"),
              let array = try? NSKeyedUnarchiver.unarchivedObject(
                ofClasses: [NSArray.self, Tag.self, NSString.self, NSDate.self, NSUUID.self],
                from: data) as? [Tag]
        else { return [] }
        return array
    }
}
