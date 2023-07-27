//
//  BibolocApp.swift
//  Biboloc
//
//  Created by awa on 2023/07/21.
//

import SwiftUI
import Foundation

@main
struct BibolocApp: App {
    @StateObject var database = Database()
    init() {}
    
    var body: some Scene {
        WindowGroup {
            ContentView(database: database)
                .onAppear() {
                    database.mergeUserDefault()
                }
                .edgesIgnoringSafeArea(.all)
        }
    }
}

class Database: ObservableObject {
    // 表示用データ
    @Published var TagList: Array<Tag> = [Tag(name: "備忘録", false)]
    @Published var MemoList: Array<Memo> = [Memo(Date(), "Biboloc チュートリアル", [Tag(name: "備忘録", false)], false)]
    
    
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
    }
    
    // Memo 更新
    func createMemo(memo: Memo) {
        MemoList += [memo]
        MemoList = MemoList.sorted {
                return $0.created_at < $1.created_at
            }
        setUserDefault(object: MemoList, key: "MemoData")
    }
    
    func updateMemo() {
        MemoList = MemoList.sorted {
                return $0.created_at < $1.created_at
            }
        setUserDefault(object: MemoList, key: "MemoData")
    }
    
    // Tag 更新
    func updateTag(tag: Tag) {
        TagList += [tag]
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
        guard let array = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Memo]
        else {
            return []
        }
        return array
    }
    
    func loadTagUserDefault() -> [Tag] {
        guard let data = UserDefaults.standard.data(forKey: "TagData") else {
            return []
        }
        guard let array = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Tag]
        else {
            return []
        }
        return array
    }
}
