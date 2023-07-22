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
    init() {
        database.mergeUserDefault()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(database: database)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

class Database: ObservableObject {
    // 表示用データ
    @Published var TagList: Array<Tag> = [Tag(name: "備忘録")]
    @Published var MemoList: Array<Memo> = [Memo(created_at: Date(), text: "Biboloc チュートリアル", tag: [Tag(name: "備忘録")])]
    
    
    // 内部ストレージ、表示用データを合わせる
    func mergeUserDefault() {
        // ストレージ 確認（メモ）
        if let MemoDecoded = UserDefaults.standard.object(forKey: "MemoData") {
            do {
                let MemoData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(MemoDecoded as! Data) as! [Memo]
                // あれば取得
                self.MemoList = MemoData
            } catch {
                setUserDefault(root: self.MemoList, key: "MemoData")
            }
        } else {
            // なければ保存
            setUserDefault(root: self.MemoList, key: "MemoData")
        }
        
        // ストレージ 確認（タグ）
        if let TagDecoded = UserDefaults.standard.object(forKey: "TagData") {
            do {
                let TagData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(TagDecoded as! Data) as! [Tag]
                // あれば取得
                self.TagList = TagData
            } catch {
                setUserDefault(root: self.TagList, key: "TagData")
            }
        } else {
            // なければ保存
            setUserDefault(root: self.TagList, key: "TagData")
        }
    }
    
    
    // Memo 更新
    func updateMemo(memo: Memo) {
        self.MemoList += [memo]
        setUserDefault(root: self.MemoList, key: "MemoData")
    }
    
    // Tag 更新
    func updateTag(TagList: [Tag]) {
        self.TagList = TagList
        setUserDefault(root: TagList, key: "TagData")
    }
    
    // UserDefault に保存
    func setUserDefault(root: Any, key: String) {
        do {
            let TagEncoded = try NSKeyedArchiver.archivedData(
                withRootObject: root,
                requiringSecureCoding: false
            )
            
            UserDefaults.standard.set(TagEncoded, forKey: key)
            
        } catch let e {
            print(e)
            print("failed to save \(key)")
        }
    }
}
