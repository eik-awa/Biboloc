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
                TextEditor(text: $text)
                    .focused(self.$focus)
                
                Button(action: {
                    isDisplay_MemoCreate = false
                    database.updateMemo(
                        memo: Memo(created_at: Date(), text: text, tag: [])
                    )
                    text = ""
                }) {
                    Text("登録")
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
