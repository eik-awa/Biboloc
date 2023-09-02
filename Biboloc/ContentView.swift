//
//  ContentView.swift
//  Biboloc
//
//  Created by awa on 2023/07/21.
//

import SwiftUI

struct ContentView: View {
    // メモデータ
    @ObservedObject var database: Database
    // 表示切り替え
    @State private var display_mode = AppConstants.DISPLAY_MODE_MAIN
    // 新規 or 編集
    @State private var is_New = true
    // メモ編集（ポップアップ）の表示
    @State private var is_Display_MemoEdit = false
    // 選択中のメモ
    @State private var selected_memo = Memo(created_at: Date(), text: "", tag: [], favorite: false)
    
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
                        .frame(width: 120, height: 60)
                }
                .frame(height: 100)
                
                Spacer()
                
                // 表示切り替え
                switch display_mode {
                case AppConstants.DISPLAY_MODE_MAIN:
                    MainView(
                        database: database,
                        is_New: $is_New,
                        is_Display_MemoEdit: $is_Display_MemoEdit,
                        selected_memo: $selected_memo
                    )
                    
                case AppConstants.DISPLAY_MODE_HASHTAG:
                    HashTagView()
                    
                    
                case AppConstants.DISPLAY_MODE_FAVORITE:
                    FavoriteView(
                        database: database,
                        is_New: $is_New,
                        is_Display_MemoEdit: $is_Display_MemoEdit,
                        selected_memo: $selected_memo
                    )
                    
                case AppConstants.DISPLAY_MODE_SETTING:
                    SettingView()
                default:
                    MainView(
                        database: database,
                        is_New: $is_New,
                        is_Display_MemoEdit: $is_Display_MemoEdit,
                        selected_memo: $selected_memo
                    )
                }
            }
            
            Rectangle()
            // ポップアップ系画面の表示中は、背景をグレーにする
                .fill((is_Display_MemoEdit) ? .gray.opacity(0.7) : .clear)
                .edgesIgnoringSafeArea(.all)
            
            // タップすると、ポップアップが消える
                .onTapGesture {
                    is_Display_MemoEdit = false
                    // キーボードを非表示に
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            
            // フッター（メニュー）
            VStack {
                Spacer()
                ZStack {
                    VStack {
                        Spacer()
                        
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: UIScreen.main.bounds.size.width)
                                .edgesIgnoringSafeArea(.all)
                                .cornerRadius(40)
                                .frame(height: 100)
                            
                            VStack {
                                
                                Spacer()
                                
                                HStack(spacing: UIScreen.main.bounds.size.width / 5 - 30) {
                                    Spacer()
                                    
                                    Button(action: {
                                        display_mode = AppConstants.DISPLAY_MODE_SETTING
                                    }) {
                                        Image(systemName: "gearshape")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 30, design: .serif))
                                            .frame(width: 30, height: 30)
                                    }
                                    
                                    Button(action: {
                                        display_mode = AppConstants.DISPLAY_MODE_MAIN
                                    }) {
                                        Image(systemName: "doc.text")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 30, design: .serif))
                                            .frame(width: 30, height: 30)
                                    }
                                    
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 30, height: 30)
                                    
                                    Button(action: {
                                        display_mode = AppConstants.DISPLAY_MODE_HASHTAG
                                    }) {
                                        Image(systemName: "number")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 30, design: .serif))
                                            .frame(width: 30, height: 30)
                                    }
                                    
                                    Button(action: {
                                        display_mode = AppConstants.DISPLAY_MODE_FAVORITE
                                    }) {
                                        Image(systemName: "star")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 30, design: .serif))
                                            .frame(width: 30, height: 30)
                                    }
                                    
                                    Spacer()
                                }
                                Spacer()
                                
                                Rectangle()
                                    .fill(.clear)
                                    .frame(width: UIScreen.main.bounds.size.width, height: 20)
                            }
                        }
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
                                selected_memo = Memo(
                                    created_at: Date(),
                                    text: "",
                                    tag: [],
                                    favorite: false
                                )
                                is_New = true
                                is_Display_MemoEdit = true
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
            .popup(isPresented: $is_Display_MemoEdit){
                MemoEdit(
                    is_New: $is_New,
                    is_Display_MemoEdit: $is_Display_MemoEdit,
                    memo: $selected_memo,
                    database: database
                )
            }
        }
        // 時計の非表示（Appプレビュー撮影用）
        .statusBar(hidden: true)
    }
}

struct MainView: View {
    @ObservedObject var database: Database
    @Binding var is_New: Bool
    @Binding var is_Display_MemoEdit: Bool
    @Binding var selected_memo: Memo
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(0..<database.MemoList.count, id: \.self) {
                num in
                if !is_SameMonth(MemoList: database.MemoList, num: num) {
                    Text("\(ConvertYearMonth(date: database.MemoList[num].created_at))")
                }
                
                switch StatusDate_Prev_and_Next(MemoList: database.MemoList, num: num) {
                case AppConstants.CALENDAR_NOT_SAME_DATE_PREV_AND_NEXT:
                    // テキスト
                    MemoView_DisplayDate(
                        memo: $database.MemoList[num],
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
                        memo: $database.MemoList[num],
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
                        memo: $database.MemoList[num],
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
                        memo: $database.MemoList[num],
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
            Rectangle()
                .fill(.clear)
                .frame(height: 110)
        }
        .frame(height: UIScreen.main.bounds.size.height - 100)
        
        Spacer()
        
    }
}


// Date型から年月に変換
func ConvertYearMonth(date: Date) -> String {
    let calendar = Calendar(identifier: .gregorian)
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    
    return "\(year). \(month)"
}

// Date型から曜日に変換
func ConvertWeekDay(date: Date) -> String {
    let calendar = Calendar(identifier: .gregorian)
    let WeekDayNumber = calendar.component(.weekday, from: date)
    
    return calendar.weekdaySymbols[WeekDayNumber - 1]
}

// Date型から日付に変換
func ConvertDay(date: Date) -> Int {
    let calendar = Calendar(identifier: .gregorian)
    let day = calendar.component(.day, from: date)
    
    return day
}

// 現在時刻を表示 2023.7.27 Thu 19:20
func ConvertTime(date: Date) -> String {
    /// DateFomatterクラスのインスタンス生成
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US")
    dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
    
    dateFormatter.calendar = Calendar(identifier: .gregorian)
    dateFormatter.dateFormat = "yyyy. M. d E HH:mm"
    
    /// データ変換
    return dateFormatter.string(from: date)
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
                let this_day = ConvertDay(date: MemoList[num].created_at)
                let last_day = ConvertDay(date: MemoList[num - 1].created_at)
                
                if this_day == last_day {
                    return true
                }
                return false
            }
            return false
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
            let last_month = ConvertYearMonth(date: MemoList[num - 1].created_at)
            let this_month = ConvertYearMonth(date: MemoList[num].created_at)
            
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
