//
//  ContentView.swift
//  Biboloc
//
//  Created by awa on 2023/07/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var database: Database
    @State private var is_Display_MemoCreate = false
    @State private var is_Display_MemoUpdate = false
    @State private var selected_memo = Memo(Date(), "", [], false)
    var body: some View {
        ZStack {
            // 背景
            Rectangle()
                .fill(Color.BaseColor.opacity(0.2))
                .ignoresSafeArea()
            
            VStack {
                // ヘッダー
                VStack {
                    Spacer()
                    
                    Image("logo_water")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 50)
                }
                .frame(height: 100)
                
                Spacer()
                
                // スクロール
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(0..<database.MemoList.count, id: \.self) {
                        num in
                        
                        if !is_SameMonth(MemoList: database.MemoList, num: num) {
                            Text("\(ConvertYearMonth(memo: database.MemoList[num]))")
                        }
                        
                        switch StatusDate_Prev_and_Next(MemoList: database.MemoList, num: num) {
                        case AppConstants.CALENDAR_NOT_SAME_DATE_PREV_AND_NEXT:
                            // テキスト
                                MemoDateView(
                                    memo: $database.MemoList[num],
                                    is_Display_MemoUpdate: $is_Display_MemoUpdate,
                                    selected_memo: $selected_memo
                                )
                                .frame(width: UIScreen.main.bounds.size.width * 0.9, height: AppConstants.MEMO_HEIGHT)
                                .cornerRadius(10)
                                .padding(.top, 4)
                                .padding(.bottom, 4)
                            
                        case AppConstants.CALENDAR_SAME_DATE_NEXT_ONLY:
                                // テキスト
                                MemoDateView(
                                    memo: $database.MemoList[num],
                                    is_Display_MemoUpdate: $is_Display_MemoUpdate,
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
                                memo: $database.MemoList[num],
                                is_Display_MemoUpdate: $is_Display_MemoUpdate,
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
                                memo: $database.MemoList[num],
                                is_Display_MemoUpdate: $is_Display_MemoUpdate,
                                selected_memo: $selected_memo
                            )
                            .frame(width: UIScreen.main.bounds.size.width * 0.9, height: AppConstants.MEMO_HEIGHT)
                            .padding(.top, -4)
                            .padding(.bottom, -4)
                            
                        default:
                            Text("error")
                        }
                    }
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 110)
                }
                .frame(height: UIScreen.main.bounds.size.height - 100)
                
                Spacer()
                
            }
            
            
            Rectangle()
            // ポップアップ系画面の表示中は、背景をグレーにする
            //スタンプカード画面、スタンプ獲得画面
                .fill((is_Display_MemoCreate || is_Display_MemoUpdate) ? .gray.opacity(0.7) : .clear)
                .edgesIgnoringSafeArea(.all)
            
            // タップすると、ポップアップが消える
                .onTapGesture {
                    is_Display_MemoCreate = false
                    is_Display_MemoUpdate = false
                }
            
            
            VStack {
                Spacer()
                ZStack {
                    VStack {
                        Spacer()
                        
                        Rectangle()
                            .fill(Color.white)
                            .frame(maxWidth: .infinity)
                            .edgesIgnoringSafeArea(.all)
                            .cornerRadius(40)
                            .frame(height: 100)
                    }
                    
                    ZStack {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color.MainColor)
                                    .frame(width: 70, height: 70)
                                    .shadow(color: .gray.opacity(0.5), radius: 10, x: 1, y: 1)
                                
                                Image(systemName: "plus")
                                    .foregroundColor(.black)
                                    .font(.system(size: 30, design: .serif))
                                    .frame(width: 30, height: 30)
                            }
                            
                            Spacer()
                        }
                        
                        VStack{
                            Button(action: {
                                is_Display_MemoCreate = true
                            }) {
                                Circle()
                                    .fill(.clear)
                                    .frame(width: 70, height: 70)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(height: 130)
                .edgesIgnoringSafeArea(.all)
            }
            .popup(isPresented: $is_Display_MemoCreate){
                MemoCreate(
                    is_Display_MemoCreate: $is_Display_MemoCreate,
                    database: database
                )
            }
            
            .popup(isPresented: $is_Display_MemoUpdate){
                MemoUpdate(
                    isDisplay_MemoUpdate: $is_Display_MemoUpdate,
                    memo: $selected_memo,
                    database: database
                )
            }
        }
    }
}


// Date型から年月に変換
func ConvertYearMonth(memo: Memo) -> String {
    let calendar = Calendar(identifier: .gregorian)
    let year = calendar.component(.year, from: memo.created_at ?? Date())
    let month = calendar.component(.month, from: memo.created_at ?? Date())
    
    return "\(year) / \(month)"
}

// Date型から曜日に変換
func ConvertWeekDay(memo: Memo) -> String {
    let calendar = Calendar(identifier: .gregorian)
    let WeekDayNumber = calendar.component(.weekday, from: memo.created_at ?? Date())
    
    return calendar.weekdaySymbols[WeekDayNumber - 1]
}

// Date型から日付に変換
func ConvertDay(memo: Memo) -> Int {
    let calendar = Calendar(identifier: .gregorian)
    let day = calendar.component(.day, from: memo.created_at ?? Date())
    
    return day
}

// 前後の日付が同じか判定
func StatusDate_Prev_and_Next(MemoList: [Memo], num: Int) -> Int {
    var status_date: Int = 0
    // 先頭の場合
    // 後ろの日付のみ比較
    if num == 0 {
        if is_SameDate(MemoList: MemoList, num: num+1) {
            status_date = AppConstants.CALENDAR_SAME_DATE_NEXT_ONLY
        } else {
            status_date = AppConstants.CALENDAR_NOT_SAME_DATE_PREV_AND_NEXT
        }
    }
    
    // 最後尾の場合
    // 前の日付のみ比較
    else if num == MemoList.count {
        if is_SameDate(MemoList: MemoList, num: num) {
            status_date = AppConstants.CALENDAR_SAME_DATE_PREV_ONLY
        } else {
            status_date = AppConstants.CALENDAR_NOT_SAME_DATE_PREV_AND_NEXT
        }
    }
    
    // それ以外
    // 前後の日付を比較
    else {
        let is_sameDate_prev_now = is_SameDate(MemoList: MemoList, num: num)
        let is_sameDate_now_next = is_SameDate(MemoList: MemoList, num: num+1)
        
        if is_sameDate_prev_now {
            if is_sameDate_now_next {
                status_date = AppConstants.CALENDAR_SAME_DATE_PREV_AND_NEXT
            } else {
                status_date = AppConstants.CALENDAR_SAME_DATE_PREV_ONLY
            }
        } else {
            if is_sameDate_now_next {
                status_date = AppConstants.CALENDAR_SAME_DATE_NEXT_ONLY
            } else {
                status_date = AppConstants.CALENDAR_NOT_SAME_DATE_PREV_AND_NEXT
            }
        }
    }
    return status_date
}

// 1つ前のメモの日付が同じか判定
func is_SameDate(MemoList: [Memo], num: Int) -> Bool {
    
    // 先頭のメモは false を返す
    if num != 0 {
        if num < MemoList.count {
            if is_SameMonth(MemoList: MemoList, num: num) {
                let this_day = ConvertDay(memo: MemoList[num])
                let last_day = ConvertDay(memo: MemoList[num - 1])
                
                if this_day == last_day {
                    return true
                }
                return false
            }
            return true
        }
        return false
    }
    return false
}

// 1つ前のメモの年月が同じか判定
func is_SameMonth(MemoList: [Memo], num: Int) -> Bool {
    // 先頭のメモは false を返す
    if num != 0 {
        if num < MemoList.count {
            let last_month = ConvertYearMonth(memo: MemoList[num - 1])
            let this_month = ConvertYearMonth(memo: MemoList[num])
            
            if this_month == last_month {
                return true
            }
            return false
        }
        return true
    }
    return false
}

// カラーコード
extension Color {
    static var BaseColor = Color("BaseColor")
    static var MainColor = Color("MainColor")
}

// ポップアップの表示設定
extension View {
    
    func popup<Content: View>(isPresented: Binding<Bool>, content: () -> Content) -> some View {
        
        if isPresented.wrappedValue {
        }
        
        return ZStack {
            self
            
            content()
                .opacity(isPresented.wrappedValue ? 1 : 0)
                .scaleEffect(isPresented.wrappedValue ? 1 : 0.001)
                .animation(.easeIn(duration: 0.2), value: isPresented.wrappedValue)
        }
    }
}

// 一部の角のみを丸くしたViewを作成する
struct PartlyRoundedCornerView: UIViewRepresentable {
    let cornerRadius: CGFloat
    let maskedCorners: CACornerMask
    
    func makeUIView(context: UIViewRepresentableContext<PartlyRoundedCornerView>) -> UIView {
        
        let uiView = UIView()
        uiView.layer.cornerRadius = cornerRadius
        uiView.layer.maskedCorners = maskedCorners
        uiView.backgroundColor = .white
        return uiView
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PartlyRoundedCornerView>) {
    }
}

// Binding にInt 型を入れる
extension Binding where Value == Int {
    func IntToStrDef(_ def: Int) -> Binding<String> {
        return Binding<String>(get: {
            return String(self.wrappedValue)
        }) { value in
            self.wrappedValue = Int(value) ?? def
        }
    }
}
