//
//  PasscodeSettingView.swift
//  Biboloc
//
//  Created by awa on 2026/04/05.
//

import SwiftUI
import LocalAuthentication

struct PasscodeSettingView: View {
    @Binding var isPresented: Bool
    
    @State private var hasPasscode: Bool = false
    @State private var biometricEnabled: Bool = false
    @State private var showSetPasscode = false
    @State private var showChangePasscode = false
    @State private var showRemovePasscodeAlert = false
    @State private var canUseBiometrics = false
    
    var body: some View {
        VStack {
            HStack {
                Text("パスワード設定")
                    .font(.headline)
                    .bold()
                    .padding(.leading, 20)
                Spacer()
            }
            .padding(.top, 16)
            
            List {
                // パスコード ON/OFF
                Section {
                    if hasPasscode {
                        // パスコード変更
                        Button(action: {
                            showChangePasscode = true
                        }) {
                            Text("パスコードを変更")
                                .foregroundColor(.black.opacity(0.8))
                        }
                        
                        // パスコード解除
                        Button(action: {
                            showRemovePasscodeAlert = true
                        }) {
                            Text("パスコードを解除")
                                .foregroundColor(.red)
                        }
                    } else {
                        Button(action: {
                            showSetPasscode = true
                        }) {
                            Text("パスコードを設定")
                                .foregroundColor(.black.opacity(0.8))
                        }
                    }
                } header: {
                    Text("パスコード")
                        .foregroundColor(.black.opacity(0.8))
                        .font(.footnote)
                        .bold()
                }
                
                // 生体認証 (パスコード設定時のみ表示)
                if hasPasscode && canUseBiometrics {
                    Section {
                        Toggle(isOn: $biometricEnabled) {
                            Text(biometricLabel())
                                .foregroundColor(.black.opacity(0.8))
                        }
                        .tint(Color.BaseColor)
                        .onChange(of: biometricEnabled) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "BiometricEnabled")
                        }
                    } header: {
                        Text("生体認証")
                            .foregroundColor(.black.opacity(0.8))
                            .font(.footnote)
                            .bold()
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .onAppear {
            hasPasscode = KeychainHelper.hasPasscode()
            biometricEnabled = UserDefaults.standard.bool(forKey: "BiometricEnabled")
            checkBiometricAvailability()
        }
        .sheet(isPresented: $showSetPasscode) {
            PasscodeInputView(
                mode: .set,
                onComplete: {
                    hasPasscode = true
                    showSetPasscode = false
                },
                onCancel: {
                    showSetPasscode = false
                }
            )
        }
        .sheet(isPresented: $showChangePasscode) {
            PasscodeInputView(
                mode: .change,
                onComplete: {
                    showChangePasscode = false
                },
                onCancel: {
                    showChangePasscode = false
                }
            )
        }
        .alert("パスコードを解除しますか？", isPresented: $showRemovePasscodeAlert) {
            Button("いいえ", role: .cancel) {}
            Button("はい", role: .destructive) {
                KeychainHelper.deletePasscode()
                UserDefaults.standard.set(false, forKey: "BiometricEnabled")
                hasPasscode = false
                biometricEnabled = false
            }
        }
    }
    
    private func checkBiometricAvailability() {
        let context = LAContext()
        canUseBiometrics = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: nil
        )
    }
    
    private func biometricLabel() -> String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: nil
        )
        switch context.biometryType {
        case .faceID:
            return "Face IDで解除"
        case .touchID:
            return "Touch IDで解除"
        default:
            return "生体認証で解除"
        }
    }
}

// パスコード入力画面（設定・変更用）
struct PasscodeInputView: View {
    enum Mode {
        case set
        case change
    }
    
    let mode: Mode
    let onComplete: () -> Void
    let onCancel: () -> Void
    
    @State private var step: InputStep = .enterNew
    @State private var firstEntry = ""
    @State private var currentInput = ""
    @State private var isError = false
    @State private var errorMessage = ""
    
    enum InputStep {
        case verifyOld
        case enterNew
        case confirmNew
    }
    
    var body: some View {
        ZStack {
            Color.BaseColor.opacity(0.1).ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack {
                    Button("キャンセル") { onCancel() }
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                }
                
                Spacer()
                
                Text(promptText())
                    .font(.headline)
                
                // ドット表示 (最大6桁)
                HStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { index in
                        Circle()
                            .fill(index < currentInput.count
                                  ? Color.BaseColor
                                  : Color.gray.opacity(0.3))
                            .frame(width: 14, height: 14)
                    }
                }
                
                if isError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                } else {
                    Text(" ")
                        .font(.caption)
                }
                
                Text("4〜6桁の数字を入力してください")
                    .font(.caption)
                    .foregroundColor(.gray)
                
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
                    HStack(spacing: 24) {
                        // 確定ボタン (4桁以上入力されたら表示)
                        if currentInput.count >= 4 {
                            Button(action: { confirmInput() }) {
                                Text("確定")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 70, height: 70)
                                    .background(Color.BaseColor)
                                    .cornerRadius(35)
                            }
                        } else {
                            Rectangle().fill(.clear).frame(width: 70, height: 70)
                        }
                        
                        NumberButton(number: "0") {
                            appendDigit("0")
                        }
                        
                        Button(action: {
                            if !currentInput.isEmpty {
                                currentInput.removeLast()
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
            if mode == .change {
                step = .verifyOld
            } else {
                step = .enterNew
            }
        }
    }
    
    private func promptText() -> String {
        switch step {
        case .verifyOld:
            return "現在のパスコードを入力"
        case .enterNew:
            return "新しいパスコードを入力"
        case .confirmNew:
            return "もう一度入力してください"
        }
    }
    
    private func appendDigit(_ digit: String) {
        guard currentInput.count < 6 else { return }
        currentInput += digit
        isError = false
    }
    
    private func confirmInput() {
        switch step {
        case .verifyOld:
            if KeychainHelper.verifyPasscode(currentInput) {
                currentInput = ""
                step = .enterNew
            } else {
                isError = true
                errorMessage = "パスコードが違います"
                currentInput = ""
            }
            
        case .enterNew:
            firstEntry = currentInput
            currentInput = ""
            step = .confirmNew
            
        case .confirmNew:
            if currentInput == firstEntry {
                let _ = KeychainHelper.savePasscode(currentInput)
                onComplete()
            } else {
                isError = true
                errorMessage = "パスコードが一致しません"
                currentInput = ""
                step = .enterNew
                firstEntry = ""
            }
        }
    }
}
