//
//  MemoCreate.swift
//  Biboloc
//
//  Created by awa on 2023/07/22.
//

import SwiftUI

struct MemoEdit: View {
    // ２つのテキストフィールドを制御
    enum Field: Hashable {
        case memo
        case tag
    }
    @State private var is_Display_deleteAlart = false
    // メニュー
    var menu: some View {
        Menu(content: {
            if memo.favorite {
                Button(action: {
                    memo.favorite = false
                    database.updateMemo()
                }, label: {
                    Image(systemName: "star")
                    Text("お気に入り解除")
                })
            } else {
                Button(action: {
                    memo.favorite = true
                    database.updateMemo()
                }, label: {
                    Image(systemName: "star")
                    Text("お気に入り")
                })
            }
            Button(role: .destructive,action: {
                self.is_Display_deleteAlart = true
            }, label: {
                Image(systemName: "trash")
                Text("削除")
            })
        }, label: {
            Image(systemName: "list.bullet")
                .foregroundColor(.black)
                .font(.system(size: 30, design: .serif))
                .frame(width: 30,height: 30)
            
        }).alert(isPresented: $is_Display_deleteAlart) {
            Alert(
                title: Text("このメモを削除しますか？"),
                primaryButton: .cancel(Text("いいえ")) {
                    is_Display_deleteAlart = false
                }, secondaryButton: .destructive(Text("はい")) {
                    focusedField = nil
                    is_Display_MemoEdit = false
                    database.deleteMemo(memo: memo)
                }
            )}
    }
    
    // 新規/編集 フラグ
    @Binding var is_New: Bool
    // 画面表示 フラグ
    @Binding var is_Display_MemoEdit: Bool
    // memo モデル
    @Binding var memo: Memo
    // メモ、タグデータ
    @ObservedObject var database: Database
    // キーボードの表示制御
    @FocusState var focusedField: Field?
    // タグのテキストフィールド
    @State private var NewTag = ""
    
    var body: some View {
        ZStack {
            
            // メモ編集画面内をクリックするとキーボードを非表示にする
            if (focusedField != nil) {
                Button(action: {
                    focusedField = nil
                }) {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 320, height: 440)
                        .padding()
                } // Button 終わり
            } // if 文 終わり
            
            VStack {
                ZStack {
                    // 日時変更
                    HStack {
                        Spacer()
                        
                        DatePicker(
                            "", // ラベル
                            selection: $memo.created_at,
                            displayedComponents: [.hourAndMinute, .date]  // 日付と時間
                        )
                        .environment(\.locale, Locale(identifier: "ja_JP")) // 日本時間
                        .labelsHidden() // ラベル非表示
                        
                        Spacer()
                    } // HStack 終わり
                    VStack {
                        // メニュー
                        HStack {
                            Spacer() // 右寄せ
                            menu
                        }
                        Spacer()
                    }
                }.frame(height: 40)
                
                ZStack {
                    TextEditor(text: $memo.text)
                        .focused($focusedField, equals: .memo)
                    
                    
                    Button(action: {
                        focusedField = nil
                    }) {
                        Rectangle()
                            .fill(.clear)
                            .padding()
                    }
                }
                
                Spacer()
                
                
                VStack {
                    ScrollView (.horizontal, showsIndicators: false){
                        HStack {
                            // タグ追加
                            TextField("#", text: $NewTag)
                                .foregroundColor(.white)
                                .accentColor(.white)
                                .padding(10)
                                .background(Color.gray.opacity(0.4))
                                .frame(width: 100,height: 30)
                                .cornerRadius(15)
                                .focused($focusedField, equals: .tag)
                                .bold()
                            
                            
                            if NewTag != "" {
                                Button(action: {
                                    if NewTag != "" {
                                        if (IndexTag(TagList: database.TagList, name: NewTag) == -1) {
                                            database.createTag(tag: Tag(name: NewTag, used_at: Date()))
                                        } else {
                                            database.TagList[IndexTag(TagList: database.TagList, name: NewTag)].used_at = Date()
                                            database.updateTag()
                                        }
                                        
                                        if (IndexTag(TagList: memo.tag, name: NewTag) == -1) {
                                            memo.tag.append(Tag(name: NewTag, used_at: Date()))
                                            database.updateMemo()
                                        }
                                        NewTag = ""
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(Color.MainColor)
                                        .font(.system(size: 30, weight: .bold, design: .serif))
                                        .frame(width: 30,height: 30)
                                }
                            }
                            ForEach(database.TagList, id: \.self) { tag in
                                
                                if (IndexTag(TagList: memo.tag, name: tag.name) != -1) {
                                    Button(action: {
                                        if (IndexTag(TagList: memo.tag, name: tag.name) != -1) {
                                            memo.tag.remove(at: IndexTag(TagList: memo.tag, name: tag.name))
                                            database.updateMemo()
                                        }
                                    }) {
                                        Text("# \(tag.name)")
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .bold()
                                            .frame(height: 30)
                                            .background(Color.BaseColor.opacity(0.7))
                                            .cornerRadius(15)
                                    }
                                }
                            }
                            ForEach(database.TagList, id: \.self) { tag in
                                
                                if (IndexTag(TagList: memo.tag, name: tag.name) == -1) {
                                    Button(action: {
                                        memo.tag.append(tag)
                                        tag.used_at = Date()
                                        database.updateMemo()
                                        database.updateTag()
                                    }) {
                                        Text("# \(tag.name)")
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .bold()
                                            .frame(height: 30)
                                            .background(Color.gray.opacity(0.4))
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                    }
                }.frame(height: 40)
                
                VStack {
                    Button(action: {
                        focusedField = nil
                        is_Display_MemoEdit = false
                        if is_New {
                            database.createMemo(
                                memo: memo
                            )
                        } else {
                            database.updateMemo()
                        }
                        if NewTag != "" {
                            if (IndexTag(TagList: database.TagList, name: NewTag) == -1) {
                                database.createTag(tag: Tag(name: NewTag, used_at: Date()))
                            } else {
                                database.TagList[IndexTag(TagList: database.TagList, name: NewTag)].used_at = Date()
                                database.updateTag()
                            }
                            
                            if (IndexTag(TagList: memo.tag, name: NewTag) == -1) {
                                memo.tag.append(Tag(name: NewTag, used_at: Date()))
                                database.updateMemo()
                            }
                            NewTag = ""
                        }
                    }) {
                        Text("登録")
                            .foregroundColor(.white)
                            .padding(5)
                            .frame(width: 320, height: 40)
                            .bold()
                            .background(Color.BaseColor)
                            .cornerRadius(20)
                        
                    }
                }
                .frame(height: 50)
                
            }
            .frame(width: 320, height: 440)
            .padding()
            .scaledToFit()
            .background(.white)
        }
    }
}

func IndexTag(TagList: [Tag], name: String) -> Int {
    if let num = TagList.firstIndex(where: {
        $0.name == name
    }) {
        return num
    }
    return -1
}
