//
//  LockScreenView.swift
//  Biboloc
//
//  Created by awa on 2026/04/05.
//

import SwiftUI
import LocalAuthentication

struct LockScreenView: View {
    @Binding var isUnlocked: Bool
    let passcodeLength: Int
    
    @State private var enteredPasscode = ""
    @State private var isError = false
    @State private var showBiometricButton = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.BaseColor.opacity(0.2))
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image("logo_water")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 60)
                
                // パスコード入力表示（ドット）
                HStack(spacing: 16) {
                    ForEach(0..<passcodeLength, id: \.self) { index in
                        Circle()
                            .fill(index < enteredPasscode.count
                                  ? Color.BaseColor
                                  : Color.gray.opacity(0.3))
                            .frame(width: 16, height: 16)
                    }
                }
                .padding(.top, 20)
                
                if isError {
                    Text("パスコードが違います")
                        .foregroundColor(.red)
                        .font(.caption)
                } else {
                    Text(" ")
                        .font(.caption)
                }
                
                // 数字キーパッド
                VStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 24) {
                            ForEach(1...3, id: \.self) { col in
                                let number = row * 3 + col
                                NumberButton(number: "\(number)") {
                                    appendDigit("\(number)")
                                }
                            }
                        }
                    }
                    
                    // 最下段: 生体認証 / 0 / 削除
                    HStack(spacing: 24) {
                        if showBiometricButton {
                            Button(action: {
                                authenticateWithBiometrics()
                            }) {
                                Image(systemName: biometricIconName())
                                    .font(.system(size: 28))
                                    .foregroundColor(.black.opacity(0.8))
                                    .frame(width: 70, height: 70)
                            }
                        } else {
                            Rectangle()
                                .fill(.clear)
                                .frame(width: 70, height: 70)
                        }
                        
                        NumberButton(number: "0") {
                            appendDigit("0")
                        }
                        
                        Button(action: {
                            if !enteredPasscode.isEmpty {
                                enteredPasscode.removeLast()
                                isError = false
                            }
                        }) {
                            Image(systemName: "delete.left")
                                .font(.system(size: 24))
                                .foregroundColor(.black.opacity(0.8))
                                .frame(width: 70, height: 70)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            let biometricEnabled = UserDefaults.standard.bool(forKey: "BiometricEnabled")
            showBiometricButton = biometricEnabled
            
            if biometricEnabled {
                authenticateWithBiometrics()
            }
        }
    }
    
    private func appendDigit(_ digit: String) {
        guard enteredPasscode.count < passcodeLength else { return }
        enteredPasscode += digit
        isError = false
        
        if enteredPasscode.count == passcodeLength {
            if KeychainHelper.verifyPasscode(enteredPasscode) {
                withAnimation{
                    isUnlocked = true
                }
            } else {
                isError = true
                enteredPasscode = ""
            }
        }
    }
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        ) else { return }
        
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "メモのロックを解除"
        ) { success, _ in
            DispatchQueue.main.async {
                if success {
                    withAnimation{
                        isUnlocked = true
                    }
                }
            }
        }
    }
    
    private func biometricIconName() -> String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: nil
        )
        switch context.biometryType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "lock"
        }
    }
}

struct NumberButton: View {
    let number: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(number)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.black.opacity(0.8))
                .frame(width: 70, height: 70)
                .background(Color.white)
                .cornerRadius(35)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
}
