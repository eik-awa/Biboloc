//
//  ContentView.swift
//  Biboloc
//
//  Created by awa on 2023/07/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var database: Database
    @State private var isDisplay_MemoCreate = false
    @State private var isDisplay_MemoUpdate = false
    
    @State private var memo_selected = Memo(Date(), "", [], false)
    @State private var displayed: String = ""
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
                    
                    Image("logo")
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
                        
                        if !is_same_month(MemoList: database.MemoList, num: num) {
                            Text("\(convert_year_month(memo: database.MemoList[num]))")
                        }
                        
                        // テキスト
                        ZStack {
                            Rectangle()
                                .fill(Color.BaseColor.opacity(0.2))
                            
                            HStack {
                                VStack {
                                    if !is_same_date(MemoList: database.MemoList, num: num) {
                                        Text("\(convert_day(memo: database.MemoList[num]))")
                                            .font(.largeTitle)
                                        
                                        Text("\(convert_WeekDay(memo: database.MemoList[num]))")
                                            .font(.footnote)
                                    }
                                }
                                .frame(width: 45, height: 50)
                                .padding()
                                
                                Text("\(database.MemoList[num].text)")
                                Spacer()
                            }
                            Button(action: {
                                isDisplay_MemoUpdate = true
                                memo_selected = database.MemoList[num]
                            }) {
                                Rectangle()
                                    .fill(.clear)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.size.width * 0.9, height: 120)
                        .mask(PartlyRoundedCornerView(
                            cornerRadius: 20,
                            maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
                        )
                    }
                }
                
                Spacer()
                
            }
            
            
            Rectangle()
            // ポップアップ系画面の表示中は、背景をグレーにする
            //スタンプカード画面、スタンプ獲得画面
                .fill((isDisplay_MemoCreate || isDisplay_MemoUpdate) ? .gray.opacity(0.7) : .clear)
                .edgesIgnoringSafeArea(.all)
            
            // タップすると、ポップアップが消える
                .onTapGesture {
                    isDisplay_MemoCreate = false
                    isDisplay_MemoUpdate = false
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
                                isDisplay_MemoCreate = true
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
            .popup(isPresented: $isDisplay_MemoCreate){
                MemoCreate(
                    isDisplay_MemoCreate: $isDisplay_MemoCreate,
                    database: database
                )
            }
            
            .popup(isPresented: $isDisplay_MemoUpdate){
                MemoUpdate(
                    isDisplay_MemoUpdate: $isDisplay_MemoUpdate,
                    memo: $memo_selected,
                    database: database
                )
            }
        }
    }
}



func convert_WeekDay(memo: Memo) -> String {
    let calendar = Calendar(identifier: .gregorian)
    let WeekDayNumber = calendar.component(.weekday, from: memo.created_at ?? Date())
    
    return calendar.weekdaySymbols[WeekDayNumber - 1]
}


func convert_year_month(memo: Memo) -> String {
    let calendar = Calendar(identifier: .gregorian)
    let year = calendar.component(.year, from: memo.created_at ?? Date())
    let month = calendar.component(.month, from: memo.created_at ?? Date())
    
    return "\(year) / \(month)"
}


func convert_day(memo: Memo) -> Int {
    let calendar = Calendar(identifier: .gregorian)
    let day = calendar.component(.day, from: memo.created_at ?? Date())
    
    return day
}


func is_same_date(MemoList: [Memo], num: Int) -> Bool {
    
    // 先頭のメモは false を返す
    if num != 0 {
        if is_same_month(MemoList: MemoList, num: num) {
            let this_day = convert_day(memo: MemoList[num])
            let last_day = convert_day(memo: MemoList[num - 1])
            
            if this_day == last_day {
                return true
            }
            return false
        }
        return false
    }
    return false
}

func is_same_month(MemoList: [Memo], num: Int) -> Bool {
    
    // 先頭のメモは false を返す
    if num != 0 {
        let this_month = convert_year_month(memo: MemoList[num])
        let last_month = convert_year_month(memo: MemoList[num - 1])
        
        if this_month == last_month {
            return true
        }
        return false
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

struct PartlyRoundedCornerView: UIViewRepresentable {
    let cornerRadius: CGFloat
    let maskedCorners: CACornerMask

    func makeUIView(context: UIViewRepresentableContext<PartlyRoundedCornerView>) -> UIView {
        // 引数で受け取った値を利用して、一部の角のみを丸くしたViewを作成する
        let uiView = UIView()
        uiView.layer.cornerRadius = cornerRadius
        uiView.layer.maskedCorners = maskedCorners
        uiView.backgroundColor = .white
        return uiView
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PartlyRoundedCornerView>) {
    }
}
