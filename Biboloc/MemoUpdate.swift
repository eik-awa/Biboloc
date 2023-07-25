//
//  MemoCreate.swift
//  Biboloc
//
//  Created by awa on 2023/07/23.
//

import SwiftUI

struct MemoUpdate: View {
    
    @Binding var isDisplay_MemoUpdate: Bool
    @Binding var memo: Memo
    @State var database: Database
    @FocusState var focus:Bool
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    
                    VStack {
                        TextEditor(text: $memo.text)
                            .focused(self.$focus)
                        
                        Button(action: {
                            isDisplay_MemoUpdate = false
                            database.updateMemo(
                                memo: memo,
                                memoData: Memo(Date(), memo.text, [], false)
                            )
                        }) {
                            Text("更新")
                                .foregroundColor(.white)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .bold()
                                .background(Color.BaseColor)
                                .cornerRadius(12)
                            
                        }
                    }
                    
                    // 閉じるボタン
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                withAnimation {
                                    focus = false
                                    isDisplay_MemoUpdate = false
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.black)
                                    .font(Font.system(size: 20))
                            }
                        }
                        Spacer()
                    }
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
