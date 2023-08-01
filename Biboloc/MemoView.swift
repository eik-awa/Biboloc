//
//  MemoView.swift
//  Biboloc
//
//  Created by awa on 2023/07/25.
//

import SwiftUI

struct MemoSwitch: View {
    @ObservedObject var database: Database
    @Binding var is_New: Bool
    @Binding var is_Display_MemoEdit: Bool
    @Binding var selected_memo: Memo
    var body: some View {
        if !is_SameMonth(MemoList: database.MemoList, num: MemoNumber) {
            Text("\(ConvertYearMonth(date: database.MemoList[MemoNumber].created_at))")
        }
        
        switch StatusDate_Prev_and_Next(MemoList: database.MemoList, num: MemoNumber) {
        case AppConstants.CALENDAR_NOT_SAME_DATE_PREV_AND_NEXT:
            // テキスト
            MemoView_DisplayDate(
                memo: $database.MemoList[MemoNumber],
                is_New: $is_New,
                is_Display_MemoEdit: $is_Display_MemoEdit,
                selected_memo: $selected_memo
            )
            .frame(width: UIScreen.main.bounds.size.width * 0.9, height: AppConstants.MEMO_HEIGHT)
            .cornerRadius(10)
            .padding(.top, 4)
            .padding(.bottom, 4)
            
        case AppConstants.CALENDAR_SAME_DATE_NEXT_ONLY:
            // テキスト
            MemoView_DisplayDate(
                memo: $database.MemoList[MemoNumber],
                is_New: $is_New,
                is_Display_MemoEdit: $is_Display_MemoEdit,
                selected_memo: $selected_memo
            )
            .frame(width: UIScreen.main.bounds.size.width * 0.9, height: AppConstants.MEMO_HEIGHT)
            .mask(PartlyRoundedCornerView(
                cornerRadius: 10,
                maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            ))
            .padding(.bottom, -4)
            .padding(.top, 4)
            
        case AppConstants.CALENDAR_SAME_DATE_PREV_ONLY:
            // テキスト
            MemoView(
                memo: $database.MemoList[MemoNumber],
                is_New: $is_New,
                is_Display_MemoEdit: $is_Display_MemoEdit,
                selected_memo: $selected_memo
            )
            .frame(width: UIScreen.main.bounds.size.width * 0.9, height: AppConstants.MEMO_HEIGHT)
            .mask(PartlyRoundedCornerView(
                cornerRadius: 10,
                maskedCorners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            ))
            .padding(.top, -4)
            .padding(.bottom, 4)
            
        case AppConstants.CALENDAR_SAME_DATE_PREV_AND_NEXT:
            // テキスト
            MemoView(
                memo: $database.MemoList[MemoNumber],
                is_New: $is_New,
                is_Display_MemoEdit: $is_Display_MemoEdit,
                selected_memo: $selected_memo
            )
            .frame(width: UIScreen.main.bounds.size.width * 0.9, height: AppConstants.MEMO_HEIGHT)
            .padding(.top, -4)
            .padding(.bottom, -4)
            
        default:
            Text("error")
        }
    }
}
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
