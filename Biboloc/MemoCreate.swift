//
//  MemoCreate.swift
//  Biboloc
//
//  Created by awa on 2023/07/22.
//

import SwiftUI

struct MemoCreate: View {
    
    @Binding var isDisplay_MemoCreate: Bool
    @State var database: Database
    @FocusState var focus:Bool
    
    @State var text = ""
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    
                    VStack {
                        TextEditor(text: $text)
                            .focused(self.$focus)
                        
                        Button(action: {
                            isDisplay_MemoCreate = false
                            database.createMemo(
                                memo: Memo(Date(), text, [], false)
                            )
                            text = ""
                        }) {
                            Text("登録")
                            
                        }
                    }
                    
                    // 閉じるボタン
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                withAnimation {
                                    focus = false
                                    isDisplay_MemoCreate = false
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
