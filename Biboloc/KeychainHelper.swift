//
//  KeychainHelper.swift
//  Biboloc
//
//  Created by awa on 2026/04/05.
//

import Foundation
import Security

enum KeychainHelper {
    
    private static let service = "com.biboloc.passcode"
    private static let account = "userPasscode"
    
    // パスコードを保存
    static func savePasscode(_ passcode: String) -> Bool {
        // 既存のパスコードを削除
        deletePasscode()
        
        guard let data = passcode.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // パスコードを読み込み
    static func loadPasscode() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let passcode = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        
        return passcode
    }
    
    // パスコードを削除
    @discardableResult
    static func deletePasscode() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // パスコードが設定されているか確認
    static func hasPasscode() -> Bool {
        return loadPasscode() != nil
    }
    
    // パスコードを検証
    static func verifyPasscode(_ input: String) -> Bool {
        guard let stored = loadPasscode() else { return false }
        return input == stored
    }
}
