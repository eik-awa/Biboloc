//
//  MemoView.swift
//  Biboloc
//
//  Created by awa on 2023/07/25.
//

import SwiftUI

struct MemoView: View {
    @Binding var memo: Memo
    @Binding var is_New: Bool
    @Binding var is_Display_MemoEdit: Bool
    @Binding var selected_memo: Memo
    var body: some View {
        
        ZStack {
            VStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: UIScreen.main.bounds.size.width * 0.7, height: 1)
                    .padding(0)
                Spacer()
            }
            
            ZStack {
                Rectangle()
                    .fill(Color.BaseColor.opacity(0.2))
                
                HStack {
                    VStack {
                    }
                    .frame(width: 45, height: 50)
                    .padding()
                    
                    Text("\(memo.text)")
                        .frame(height: 50)
                    Spacer()
                }
                Button(action: {
                    is_New = false
                    is_Display_MemoEdit = true
                    selected_memo = memo
                }) {
                    Rectangle()
                        .fill(.clear)
                }
            }
        }
    }
}


struct MemoView_DisplayDate: View {
    @Binding var memo: Memo
    @Binding var is_New: Bool
    @Binding var is_Display_MemoEdit: Bool
    @Binding var selected_memo: Memo
    var body: some View {
        
        ZStack {
            Rectangle()
                .fill(Color.BaseColor.opacity(0.2))
            
            HStack {
                VStack {
                    Text("\(ConvertDay(date: memo.created_at))")
                        .font(.largeTitle)
                    
                    Text("\(ConvertWeekDay(date: memo.created_at))")
                        .font(.footnote)
                }
                .frame(width: 45, height: 50)
                .padding()
                
                Text("\(memo.text)")
                Spacer()
            }
            Button(action: {
                is_New = false
                is_Display_MemoEdit = true
                selected_memo = memo
            }) {
                Rectangle()
                    .fill(.clear)
            }
        }
    }
}
