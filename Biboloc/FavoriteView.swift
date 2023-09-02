//
//  FavoriteView.swift
//  Biboloc
//
//  Created by awa on 2023/09/02.
//

import SwiftUI

struct FavoriteView: View {
    @ObservedObject var database: Database
    @Binding var is_New: Bool
    @Binding var is_Display_MemoEdit: Bool
    @Binding var selected_memo: Memo
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(0..<database.MemoList.count, id: \.self) {
                num in
                if database.MemoList[num].favorite {
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
        .frame(height: UIScreen.main.bounds.size.height - 100)
        
        Spacer()
        
    }
}
