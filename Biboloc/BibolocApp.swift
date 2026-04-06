//
//  BibolocApp.swift
//  Biboloc
//
//  Created by awa on 2023/07/21.
//

import SwiftUI
import Foundation
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
                            database.mergeUserDefault()
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
    // 表示用データ
    @Published var TagList: Array<Tag> = [Tag(name: "備忘録", used_at: Date())]
    @Published var DeletedMemoList: Array<Memo> = []
    @Published var MemoList: Array<Memo> = [
        Memo(
            created_at: Date(),
            text: AppConstants.HOW_TO_USE,
            tag: [Tag(name: "備忘録", used_at: Date())],
            favorite: false
        )
    ]
    
    // 内部ストレージ、表示用データを合わせる
    func mergeUserDefault() {
        
        // ストレージ 確認（メモ）
        let MemoData = loadMemoUserDefault()
        if (MemoData.count != 0) {
            MemoList = MemoData
            
        } else {
            // なければ保存
            setUserDefault(object: MemoList, key: "MemoData")
        }
        
        // ストレージ 確認（タグ）
        let TagData = loadTagUserDefault()
        if (TagData.count != 0) {
            TagList = TagData
        } else {
            // なければ保存
            setUserDefault(object: TagList, key: "TagData")
        }
        
        // ストレージ 確認（削除済みメモ）
        let DeletedMemoData = loadDeletedMemoUserDefault()
        if (DeletedMemoData.count != 0) {
            DeletedMemoList = DeletedMemoData
        }
    }
    
    // Memo 更新
    func createMemo(memo: Memo) {
        MemoList += [memo]
        MemoList = MemoList.sorted {
            return $0.created_at > $1.created_at
        }
        setUserDefault(object: MemoList, key: "MemoData")
    }
    
    func updateMemo() {
        MemoList = MemoList.sorted {
            return $0.created_at > $1.created_at
        }
        setUserDefault(object: MemoList, key: "MemoData")
    }
    
    func deleteMemo(memo: Memo) {
        if let index = MemoList.firstIndex(where: { $0.id == memo.id }) {
            MemoList.remove(at: index)
        }
        // ゴミ箱に移動
        DeletedMemoList.insert(memo, at: 0)
        setUserDefault(object: MemoList, key: "MemoData")
        setUserDefault(object: DeletedMemoList, key: "DeletedMemoData")
    }
    
    // メモ復元
    func restoreMemo(memo: Memo) {
        if let index = DeletedMemoList.firstIndex(where: { $0.id == memo.id }) {
            DeletedMemoList.remove(at: index)
        }
        MemoList.append(memo)
        MemoList = MemoList.sorted {
            return $0.created_at > $1.created_at
        }
        setUserDefault(object: MemoList, key: "MemoData")
        setUserDefault(object: DeletedMemoList, key: "DeletedMemoData")
    }
    
    // メモ完全削除
    func permanentlyDeleteMemo(memo: Memo) {
        if let index = DeletedMemoList.firstIndex(where: { $0.id == memo.id }) {
            DeletedMemoList.remove(at: index)
        }
        setUserDefault(object: DeletedMemoList, key: "DeletedMemoData")
    }
    
    // ゴミ箱を空にする
    func permanentlyDeleteAllMemos() {
        DeletedMemoList.removeAll()
        setUserDefault(object: DeletedMemoList, key: "DeletedMemoData")
    }
    
    // Tag 更新
    func createTag(tag: Tag) {
        TagList += [tag]
        TagList = TagList.sorted {
            return $0.used_at > $1.used_at
        }
        setUserDefault(object: TagList, key: "TagData")
    }
    
    func updateTag() {
        TagList = TagList.sorted {
            return $0.used_at > $1.used_at
        }
        setUserDefault(object: TagList, key: "TagData")
    }
    
    // Tag 削除
    func deleteTag(tag: Tag) {
        if let index = TagList.firstIndex(where: { $0.id == tag.id }) {
            TagList.remove(at: index)
        }
        setUserDefault(object: TagList, key: "TagData")
    }
    
    // UserDefault に保存
    func setUserDefault(object: Any, key: String) {
        guard let encoded = try? NSKeyedArchiver.archivedData(
            withRootObject: object,
            requiringSecureCoding: false
        ) else {
            return
        }
        
        UserDefaults.standard.set(encoded, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func loadMemoUserDefault() -> [Memo] {
        guard let data = UserDefaults.standard.data(forKey: "MemoData") else {
            return []
        }
        guard let array = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, Memo.self, Tag.self, NSString.self, NSDate.self, NSUUID.self, NSNumber.self], from: data) as? [Memo]
        else {
            return []
        }
        return array
    }
    
    func loadDeletedMemoUserDefault() -> [Memo] {
        guard let data = UserDefaults.standard.data(forKey: "DeletedMemoData") else {
            return []
        }
        guard let array = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, Memo.self, Tag.self, NSString.self, NSDate.self, NSUUID.self, NSNumber.self], from: data) as? [Memo]
        else {
            return []
        }
        return array
    }
    
    func loadTagUserDefault() -> [Tag] {
        guard let data = UserDefaults.standard.data(forKey: "TagData") else {
            return []
        }
        guard let array = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, Tag.self, NSString.self, NSDate.self, NSUUID.self], from: data) as? [Tag]
        else {
            return []
        }
        return array
    }
}
