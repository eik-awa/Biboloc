//
//  AppConstants.swift
//  Biboloc
//
//  Created by awa on 2023/07/25.
//

import Foundation
import UIKit

enum AppConstants {
    static let HOW_TO_USE = """
    Biboloc チュートリアル

    ◇メモ作成（＋ボタン）

    追加したいタグをクリックするだけで
    簡単にタグ登録ができます。
    解除したい場合は、もう一度タップしてください。
    タグの登録もここから行えます。



    ◇メモ編集（メニューアイコン）

    お気に入り、メモの削除が行えます。



    ◇メモ管理（メモアイコン）

    日付、月ごとにまとめて一覧が表示されます。
    メモをタップすると編集ができます。



    ◇タグ管理（＃アイコン）（作成中）

    登録済みのタグから検索ができます。
    使わないタグの削除もここから行える予定です。

    現在、作成中です。



    ◇お気に入り（星アイコン）

    お気に入りのメモを一覧で表示できます。



    ◇設定（歯車アイコン）（作成中）

    Bibolocのレビュー、共有ができます。
    パスワード設定などを追加予定です。
    削除したメモの復元も追加したいと思っています。

    現在、作成中です。
    
    """
    
    static let DISPLAY_MODE_MAIN = 0
    static let DISPLAY_MODE_FAVORITE = 1
    static let DISPLAY_MODE_HASHTAG = 2
    static let DISPLAY_MODE_SETTING = 3
    
    static let CALENDAR_NOT_SAME_DATE_PREV_AND_NEXT = 0
    static let CALENDAR_SAME_DATE_PREV_ONLY = 1
    static let CALENDAR_SAME_DATE_NEXT_ONLY = 2
    static let CALENDAR_SAME_DATE_PREV_AND_NEXT = 3
    
    static let MEMO_HEIGHT: CGFloat = 100
    static let HEADER_HEIGHT: CGFloat = 50 + (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
    static let FOOTER_HEIGHT: CGFloat = 130
}
