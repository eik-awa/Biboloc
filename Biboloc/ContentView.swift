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
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.BaseColor.opacity(0.2))
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.white.opacity(0))
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        
                        Image("logo_reverse")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 50)
                    }
                }
                .frame(height: 100)
                
                Spacer()
                
                ZStack {
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(database.MemoList.filter {
                            $0.deleted == false
                        }) { memo in
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color.BaseColor.opacity(0.2))
                                
                                HStack {
                                    VStack {
                                        Text("\(Calendar(identifier: .gregorian).component(.day, from: memo.created_at))")
                                            .font(.largeTitle)
                                        
                                        Text("\(convert_WeekDay(memo: memo))")
                                            .font(.footnote)
                                        
                                    }
                                    .padding()
                                    
                                    Spacer()
                                    Text("\(memo.text)")
                                    Spacer()
                                }
                            }
                            .frame(width: UIScreen.main.bounds.size.width * 0.9, height: 120)
                            .cornerRadius(20)
                        }
                    }
                    
                    Rectangle()
                        // ポップアップ系画面の表示中は、背景をグレーにする
                        //スタンプカード画面、スタンプ獲得画面
                            .fill((isDisplay_MemoCreate) ? .gray.opacity(0.7) : .clear)
                            .edgesIgnoringSafeArea(.all)
                        
                        // タップすると、ポップアップが消える
                            .onTapGesture {
                                isDisplay_MemoCreate = false
                            }
                }
                
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
                    
                    VStack{Button(action: {
                        isDisplay_MemoCreate = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.MainColor)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 60, design: .serif))
                                .frame(width: 60, height: 60)
                        }
                    }
                        
                        Spacer()
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
        }
    }
}



func convert_WeekDay(memo: Memo) -> String {
    let calendar = Calendar(identifier: .gregorian)
    let WeekDayNumber = calendar.component(.weekday, from: memo.created_at)
    
    return calendar.weekdaySymbols[WeekDayNumber - 1]
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
