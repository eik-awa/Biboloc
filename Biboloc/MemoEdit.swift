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
                .foregroundColor(.gray)
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
                    draftMemo = nil
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
    // 新規作成中の下書き
    @Binding var draftMemo: Memo?
    // キーボードの表示制御
    @FocusState var focusedField: Field?
    // キーボードの高さ監視
    @StateObject private var keyboard = KeyboardObserver()
    // タグのテキストフィールド
    @State private var NewTag = ""
    // 自動保存タイマー
    @State private var autoSaveTimer: Timer?
    // 自動保存設定
    @AppStorage("autoSaveEnabled") private var autoSaveEnabled = false
    
    // Dynamic Island等を考慮した上端の安全領域
    private var safeAreaTop: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 59
    }
    
    private let keyboardTopMargin: CGFloat = 40
    
    // キーボード表示時のポップアップ高さ
    private var popupHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        
        if keyboard.isShowing {
            return screenHeight - keyboard.height - safeAreaTop - 60
        } else {
            return screenHeight * 0.5
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            // メモ編集画面内をクリックするとキーボードを非表示にする
            if (focusedField != nil) {
                Button(action: {
                    focusedField = nil
                }) {
                    Rectangle()
                        .fill(.clear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } // Button 終わり
            } // if 文 終わり
            
            VStack(spacing: 0) {
                Spacer()
                if !keyboard.isShowing {
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
                            .environment(\.sizeCategory, .medium)
                            .datePickerStyle(.compact)
                            .labelsHidden() // ラベル非表示
                            .fixedSize(horizontal: true, vertical: false)
                            Spacer()
                        }
                        
                        // メニュー
                        if !is_New {
                            VStack {
                                HStack {
                                    Spacer() // 右寄せ
                                    menu
                                }
                                Spacer()
                            }
                        }
                        
                    }.frame(height: 40)
                }
                
                ZStack(alignment: .topLeading) {
                    if #available(iOS 16.0, *) {
                        TextEditor(text: $memo.text)
                            .focused($focusedField, equals: .memo)
                            .scrollContentBackground(.hidden)
                    } else {
                        TextEditor(text: $memo.text)
                            .focused($focusedField, equals: .memo)
                    }
                    
                    // キーボード表示中のみ透明ボタンを重ねて、タップで解除
                    // 解除後はボタンが消えるので、再タップでTextEditorにフォーカスが戻る
                    if focusedField != nil {
                        Button(action: {
                            focusedField = nil
                        }) {
                            Rectangle()
                                .fill(.clear)
                                .padding()
                        }
                    }
                }
                
                if !keyboard.isShowing || focusedField == .tag {
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
                                .font(.body.bold())
                            
                            
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
                                            .font(.body.bold())
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
                                            .font(.body.bold())
                                            .frame(height: 30)
                                            .background(Color.gray.opacity(0.4))
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                    }
                }.frame(height: 40)
                }
                
                if !keyboard.isShowing {
                VStack {
                    Button(action: {
                        focusedField = nil
                        is_Display_MemoEdit = false
                        // 下書きをクリア
                        draftMemo = nil
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
                            .font(.body.bold())
                            .background(Color.BaseColor)
                            .cornerRadius(20)
                        
                    }
                }
                .frame(height: 50)
                } // if !keyboard.isShowing 終わり
                
            }
            .frame(
                width: UIScreen.main.bounds.size.width * 0.8,
                height: popupHeight
            )
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(.white)
            .cornerRadius(10)
            .padding(.bottom, keyboard.isShowing ? keyboard.height - 30 : 16)
            .animation(.easeOut(duration: 0.2), value: keyboard.height)
            .onAppear {
                keyboard.addObserver()
                startAutoSaveIfNeeded()
            }
            .onChange(of: is_Display_MemoEdit) { newValue in
                if newValue && is_New {
                    focusedField = .memo
                }
            }
            .onDisappear {
                keyboard.removeObserver()
                stopAutoSave()
            }
        }
    }
    
    private func startAutoSaveIfNeeded() {
        guard autoSaveEnabled else { return }
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            guard !memo.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            if is_New {
                database.createMemo(memo: memo)
                is_New = false
            } else {
                database.updateMemo()
            }
        }
    }
    
    private func stopAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
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
