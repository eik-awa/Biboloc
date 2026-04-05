//
//  SettingView.swift
//  Biboloc
//
//  Created by awa on 2023/09/02.
//

import SwiftUI
import StoreKit

struct SettingView: View {
    @ObservedObject var database: Database
    @State var is_Display_Tutorial = false
    @State var is_Display_Trash = false
    @State var is_Display_PasscodeSetting = false
    
    init(database: Database){
        self.database = database
        //List全体の背景色の設定
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    if #available(iOS 16.0, *) {
                        List {
                            ShareList(
                                is_Display_Tutorial: $is_Display_Tutorial,
                                is_Display_Trash: $is_Display_Trash,
                                is_Display_PasscodeSetting: $is_Display_PasscodeSetting,
                                database: database
                            )
                        }
                        .scrollContentBackground(.hidden)
                        .listSectionSeparatorTint(Color.BaseColor.opacity(0.2))
                        .frame(width: UIScreen.main.bounds.size.width)
                        // iOS 16 以下は、設定メニューが灰色になる
                    } else {
                        List {
                            ShareList(
                                is_Display_Tutorial: $is_Display_Tutorial,
                                is_Display_Trash: $is_Display_Trash,
                                is_Display_PasscodeSetting: $is_Display_PasscodeSetting,
                                database: database
                            )
                        }
                        .listSectionSeparatorTint(Color.BaseColor.opacity(0.2))
                        .frame(width: UIScreen.main.bounds.size.width)
                    }
                }
                .frame(height: UIScreen.main.bounds.size.height - AppConstants.HEADER_HEIGHT - 20 - 50 - AppConstants.FOOTER_HEIGHT)
                AdMobBannerView()
                    .frame(
                        width: UIScreen.main.bounds.size.width,
                        height: 50
                    )
                
                Spacer()
            }
            
            Rectangle()
            // ポップアップ系画面の表示中は、背景をグレーにする
                .fill((is_Display_Tutorial || is_Display_Trash || is_Display_PasscodeSetting) ? .gray.opacity(0.7) : .clear)
                .edgesIgnoringSafeArea(.all)
            
            // タップすると、ポップアップが消える
                .onTapGesture {
                    is_Display_Tutorial = false
                    is_Display_Trash = false
                    is_Display_PasscodeSetting = false
                }
        }
        .popup(isPresented: $is_Display_Tutorial){
            TutorialView()
        }
        .popup(isPresented: $is_Display_Trash) {
            TrashView(database: database)
                .frame(
                    width: UIScreen.main.bounds.size.width * 0.9,
                    height: UIScreen.main.bounds.size.height * 0.6
                )
                .background(.white)
                .cornerRadius(10)
        }
        .popup(isPresented: $is_Display_PasscodeSetting) {
            PasscodeSettingView(isPresented: $is_Display_PasscodeSetting)
                .frame(
                    width: UIScreen.main.bounds.size.width * 0.9,
                    height: UIScreen.main.bounds.size.height * 0.6
                )
                .background(.white)
                .cornerRadius(10)
        }
    }
}


struct ShareList: View {
    @Binding var is_Display_Tutorial: Bool
    @Binding var is_Display_Trash: Bool
    @Binding var is_Display_PasscodeSetting: Bool
    @ObservedObject var database: Database
    @AppStorage("autoSaveEnabled") private var autoSaveEnabled = false
    
    var body: some View {
        // 共有
        Section {
            Button(action: {
                shareApp(
                    shareText: "Biboloc - メモアプリ -",
                    shareImage: Image("AppIcon"),
                    shareLink: "https://apps.apple.com/jp/app/biboloc/id6458531710"
                )
            }) {
                Text("Biboloc を紹介する")
                    .foregroundColor(.black.opacity(0.8))
            }
            .listRowSeparatorTint(Color.BaseColor.opacity(0.2))
            
            // レビュー
            Button(action: {
                RequestReview()
            }) {
                Text("レビューする")
                    .foregroundColor(.black.opacity(0.8))
            }
        } header: {
            Text("共有")
                .foregroundColor(.black.opacity(0.8))
                .font(.footnote)
                .bold()
        }
        
        Section {
            Button(action: {
                is_Display_Tutorial = true
            }) {
                Text("Biboloc 機能一覧")
                    .foregroundColor(.black.opacity(0.8))
            }
            .listRowSeparatorTint(Color.BaseColor.opacity(0.2))
            
        } header: {
            Text("使い方")
                .foregroundColor(.black.opacity(0.8))
                .font(.footnote)
                .bold()
        }
        
        // データ管理
        Section {
            Button(action: {
                is_Display_Trash = true
            }) {
                HStack {
                    Text("ゴミ箱")
                        .foregroundColor(.black.opacity(0.8))
                    Spacer()
                    if !database.DeletedMemoList.isEmpty {
                        Text("\(database.DeletedMemoList.count)")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
            }
        } header: {
            Text("データ管理")
                .foregroundColor(.black.opacity(0.8))
                .font(.footnote)
                .bold()
        }
        
        // セキュリティ
        Section {
            Button(action: {
                is_Display_PasscodeSetting = true
            }) {
                HStack {
                    Text("パスワード設定")
                        .foregroundColor(.black.opacity(0.8))
                    Spacer()
                    if KeychainHelper.hasPasscode() {
                        Text("ON")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
            }
        } header: {
            Text("セキュリティ")
                .foregroundColor(.black.opacity(0.8))
                .font(.footnote)
                .bold()
        }
        
        // 自動保存
        Section {
            Toggle(isOn: $autoSaveEnabled) {
                Text("自動保存（1分ごと）")
                    .foregroundColor(.black.opacity(0.8))
            }
            .tint(Color.BaseColor)
        } header: {
            Text("メモ")
                .foregroundColor(.black.opacity(0.8))
                .font(.footnote)
                .bold()
        }
    }
}


// 共有ボタン
func shareApp(shareText: String, shareImage: Image, shareLink: String) {
    let items = [shareText, shareImage, URL(string: shareLink)!] as [Any]
    let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    let rootVC = windowScene?.windows.first?.rootViewController
    rootVC?.present(activityVC, animated: true,completion: {})
}


// レビューボタン
func RequestReview() {
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        SKStoreReviewController.requestReview(in: scene)
    }
}


struct TutorialView: View {
    var body: some View {
        ZStack {
            Rectangle()
            .fill(.white)
            .frame(width: UIScreen.main.bounds.size.width * 0.9, height: UIScreen.main.bounds.size.height * 0.6)
            
            ScrollView(showsIndicators: false) {
                Text(AppConstants.HOW_TO_USE)
            }
            .frame(width: UIScreen.main.bounds.size.width * 0.9 - 40, height: UIScreen.main.bounds.size.height * 0.6 - 40)
        }
    }
}
