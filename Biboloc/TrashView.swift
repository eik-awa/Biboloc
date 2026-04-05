//
//  TrashView.swift
//  Biboloc
//
//  Created by awa on 2026/04/05.
//

import SwiftUI

struct TrashView: View {
    @ObservedObject var database: Database
    @State var is_Display_restoreAlert = false
    @State var is_Display_deleteAlert = false
    @State var is_Display_deleteAllAlert = false
    @State var selectedMemo: Memo? = nil
    
    var body: some View {
        VStack {
            // ヘッダー
            HStack {
                Text("ゴミ箱")
                    .font(.headline)
                    .bold()
                    .padding(.leading, 20)
                
                Spacer()
                
                if !database.DeletedMemoList.isEmpty {
                    Button(action: {
                        is_Display_deleteAllAlert = true
                    }) {
                        Text("すべて削除")
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.trailing, 20)
                    }
                }
            }
            .padding(.top, 10)
            
            if database.DeletedMemoList.isEmpty {
                Spacer()
                Text("ゴミ箱は空です。")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(database.DeletedMemoList, id: \.id) { memo in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.BaseColor.opacity(0.2))
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(memo.text)
                                        .lineLimit(2)
                                        .font(.body)
                                    
                                    Text(ConvertTime(date: memo.created_at))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading, 12)
                                
                                Spacer()
                                
                                // 復元ボタン
                                Button(action: {
                                    selectedMemo = memo
                                    is_Display_restoreAlert = true
                                }) {
                                    Image(systemName: "arrow.uturn.backward.circle")
                                        .foregroundColor(Color.BaseColor)
                                        .font(.system(size: 24))
                                }
                                .padding(.trailing, 8)
                                
                                // 完全削除ボタン
                                Button(action: {
                                    selectedMemo = memo
                                    is_Display_deleteAlert = true
                                }) {
                                    Image(systemName: "trash.circle")
                                        .foregroundColor(.red)
                                        .font(.system(size: 24))
                                }
                                .padding(.trailing, 12)
                            }
                        }
                        .frame(
                            width: UIScreen.main.bounds.size.width * 0.9 - 40,
                            height: 80
                        )
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .alert("メモを復元しますか？", isPresented: $is_Display_restoreAlert) {
            Button("いいえ", role: .cancel) { selectedMemo = nil }
            Button("はい") {
                if let memo = selectedMemo {
                    database.restoreMemo(memo: memo)
                }
                selectedMemo = nil
            }
        }
        .alert("このメモを完全に削除しますか？", isPresented: $is_Display_deleteAlert) {
            Button("いいえ", role: .cancel) { selectedMemo = nil }
            Button("はい", role: .destructive) {
                if let memo = selectedMemo {
                    database.permanentlyDeleteMemo(memo: memo)
                }
                selectedMemo = nil
            }
        } message: {
            Text("この操作は取り消せません。")
        }
        .alert("ゴミ箱を空にしますか？", isPresented: $is_Display_deleteAllAlert) {
            Button("いいえ", role: .cancel) {}
            Button("はい", role: .destructive) {
                database.permanentlyDeleteAllMemos()
            }
        } message: {
            Text("すべてのメモが完全に削除されます。\nこの操作は取り消せません。")
        }
    }
}
