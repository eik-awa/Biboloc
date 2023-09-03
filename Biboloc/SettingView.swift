//
//  SettingView.swift
//  Biboloc
//
//  Created by awa on 2023/09/02.
//

import SwiftUI
import StoreKit

struct SettingView: View {
    init(){
        //List全体の背景色の設定
        UITableView.appearance().backgroundColor = .clear
    }
    @State var is_Display_Tutorial = false
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    if #available(iOS 16.0, *) {
                        List {
                            ShareList(is_Display_Tutorial: $is_Display_Tutorial)
                        }
                        .scrollContentBackground(.hidden)
                        .listSectionSeparatorTint(Color.BaseColor.opacity(0.2))
                        .frame(width: UIScreen.main.bounds.size.width)
                        // iOS 16 以下は、設定メニューが灰色になる
                    } else {
                        List {
                            ShareList(is_Display_Tutorial: $is_Display_Tutorial)
                        }
                        .listSectionSeparatorTint(Color.BaseColor.opacity(0.2))
                        .frame(width: UIScreen.main.bounds.size.width)
                    }
                }
                .frame(height: UIScreen.main.bounds.size.height - AppConstants.HEADER_HEIGHT - 20 - 300 - AppConstants.FOOTER_HEIGHT)
                AdMobBannerView()
                    .frame(
                        width: UIScreen.main.bounds.size.width * 0.9,
                        height: 300
                    )
                
                Spacer()
            }
            
            Rectangle()
            // ポップアップ系画面の表示中は、背景をグレーにする
                .fill((is_Display_Tutorial) ? .gray.opacity(0.7) : .clear)
                .edgesIgnoringSafeArea(.all)
            
            // タップすると、ポップアップが消える
                .onTapGesture {
                    is_Display_Tutorial = false
                }
        }
        .popup(isPresented: $is_Display_Tutorial){
            TutorialView()
        }
    }
}


struct ShareList: View {
    @Binding var is_Display_Tutorial: Bool
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
