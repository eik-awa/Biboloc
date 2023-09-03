//
//  HashTagView.swift
//  Biboloc
//
//  Created by awa on 2023/09/02.
//

import SwiftUI

struct HashTagView: View {
    @ObservedObject var database: Database
    @Binding var is_New: Bool
    @Binding var is_Display_MemoEdit: Bool
    @Binding var selected_memo: Memo
    @State var text: String = ""
    @ObservedObject var keyboard: KeyboardObserver = KeyboardObserver()
    
    // テキストフィールドを制御
    enum Field: Hashable {
        case search
    }
    // キーボードの表示制御
    @FocusState var focusedField: Field?
    var body: some View {
        ZStack {
            VStack {
                
                Spacer()
                    .frame(height: (focusedField == nil) ? 0 : keyboard.height / 2)
                // 検索欄
                ZStack {
                    // 背景
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white)
                        .frame(width: UIScreen.main.bounds.size.width * 0.8,height: 36)
                    
                    HStack(spacing: 6) {
                        Spacer()
                            .frame(width: UIScreen.main.bounds.size.width * 0.15)
                        
                        // 虫眼鏡
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        VStack {
                            // テキストフィールド
                            TextField("Search", text: $text)
                                .focused($focusedField, equals: .search)
                        }.onAppear{
                            self.keyboard.addObserver()
                        }.onDisappear {
                            self.keyboard.removeObserver()
                        }
                        
                        // 検索文字が空ではない場合は、クリアボタンを表示
                        if !text.isEmpty {
                            Button {
                                text.removeAll()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                            .frame(width: UIScreen.main.bounds.size.width * 0.15)
                    }
                }
                .padding(.horizontal)
                
                if text.isEmpty {
                    // タグ一覧
                    ScrollView() {
                        FlexibleView(
                            data: database.TagList,
                            spacing: 10,
                            alignment: .leading
                        ) { tag in
                            Button(action: {
                                text = tag.name
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
                        .frame(width: UIScreen.main.bounds.size.width * 0.9)
                        .padding()
                    }
                    // 余白の設定
                    // ヘッダー + 検索欄(36) + 余白(20) + 広告(300) + フッター
                    .frame(height: UIScreen.main.bounds.size.height - AppConstants.HEADER_HEIGHT - 36 - 20 - 300 - AppConstants.FOOTER_HEIGHT)
                    
                    // 広告
                    AdMobBannerView()
                        .frame(width: UIScreen.main.bounds.size.width * 0.9, height: 300)
                }
                
                if ( !text.isEmpty && isSearchNone(database: database, text: text) == true ) {
                    Text("該当のメモは見つかりませんでした。")
                        .padding()
                    
                    AdMobBannerView()
                        .frame(
                            width: UIScreen.main.bounds.size.width * 0.9,
                            height: 300
                        )
                    
                    Spacer()
                    
                } else {
                    ZStack {
                        VStack {
                            Rectangle()
                                .fill(.clear)
                                .frame(height: 10)
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                ForEach(0..<database.MemoList.count, id: \.self) {
                                    num in
                                    if (isContainSearch(memo: database.MemoList[num], text: text)) {
                                        // テキスト
                                        MemoView_NoSpace(
                                            memo: $database.MemoList[num],
                                            is_New: $is_New,
                                            is_Display_MemoEdit: $is_Display_MemoEdit,
                                            selected_memo: $selected_memo
                                        )
                                        .frame(width: UIScreen.main.bounds.size.width * 0.9, height: AppConstants.MEMO_HEIGHT)
                                        .cornerRadius(10)
                                        .padding(.top, 4)
                                        .padding(.bottom, 4)
                                    }
                                }
                                
                                Rectangle()
                                    .fill(.clear)
                                    .frame(height: 110)
                            }
                            
                            Spacer()
                            
                        }
                    }
                }
            }
            // メモ編集画面内をクリックするとキーボードを非表示にする
            if (focusedField != nil) {
                Button(action: {
                    focusedField = nil
                }) {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                } // Button 終わり
            }
        }
    }
}


func isContainSearch(memo: Memo, text: String) -> Bool {
    for tag in memo.tag {
        if tag.name == text {
            return true
        }
    }
    return false
}

func isSearchNone(database: Database, text: String) -> Bool {
    for memo in database.MemoList {
        if isContainSearch(memo: memo, text: text) == true {
            return false
        }
    }
    return true
}
