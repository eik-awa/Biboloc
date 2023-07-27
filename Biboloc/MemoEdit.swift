//
//  MemoCreate.swift
//  Biboloc
//
//  Created by awa on 2023/07/22.
//

import SwiftUI

struct MemoEdit: View {
    
    @Binding var is_New: Bool
    @Binding var is_Display_MemoEdit: Bool
    @Binding var memo: Memo
    @State var database: Database
    @FocusState var focus:Bool
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            
                            DatePicker(
                                "",
                                selection: $memo.created_at,
                                displayedComponents: [.hourAndMinute, .date]
                            )
                            .environment(\.locale, Locale(identifier: "ja_JP"))
                            .labelsHidden()
                            
                            Spacer()
                        }
                    }
                    VStack {
                        // 閉じるボタン
                        HStack {
                            Spacer()
                            Button {
                                withAnimation {
                                    focus = false
                                    is_Display_MemoEdit = false
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.black)
                                    .font(Font.system(size: 20))
                            }
                        }
                        Spacer()
                    }
                }.frame(height: 40)
                
                TextEditor(text: $memo.text)
                    .focused(self.$focus)
                
                Spacer()
                
                Button(action: {
                    is_Display_MemoEdit = false
                    if is_New {
                        database.createMemo(
                            memo: memo
                        )
                    } else {
                        database.updateMemo()
                    }
                }) {
                    Text("登録")
                        .foregroundColor(.white)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .bold()
                        .background(Color.BaseColor)
                        .cornerRadius(12)
                    
                }
            }
            .frame(width: 320, height: 440)
            .padding()
            .scaledToFit()
            .background(.white)
            
            if self.focus == true {
                Button(action: {
                    self.focus = false
                }) {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 320, height: 440)
                        .padding()
                }
            }
        }
    }
}
