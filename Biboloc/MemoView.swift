//
//  MemoView.swift
//  Biboloc
//
//  Created by awa on 2023/07/25.
//

import SwiftUI

struct MemoView: View {
    @Binding var memo: Memo
    @Binding var is_Display_MemoUpdate: Bool
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
                    is_Display_MemoUpdate = true
                    selected_memo = memo
                }) {
                    Rectangle()
                        .fill(.clear)
                }
            }
        }
    }
}


struct MemoDateView: View {
    @Binding var memo: Memo
    @Binding var is_Display_MemoUpdate: Bool
    @Binding var selected_memo: Memo
    var body: some View {
        
        ZStack {
            Rectangle()
                .fill(Color.BaseColor.opacity(0.2))
            
            HStack {
                VStack {
                    Text("\(ConvertDay(memo: memo))")
                        .font(.largeTitle)
                    
                    Text("\(ConvertWeekDay(memo: memo))")
                        .font(.footnote)
                }
                .frame(width: 45, height: 50)
                .padding()
                
                Text("\(memo.text)")
                Spacer()
            }
            Button(action: {
                is_Display_MemoUpdate = true
                selected_memo = memo
            }) {
                Rectangle()
                    .fill(.clear)
            }
        }
    }
}
