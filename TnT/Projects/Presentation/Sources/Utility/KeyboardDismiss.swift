//
//  KeyboardDismiss.swift
//  Presentation
//
//  Created by 박민서 on 1/24/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI

/// 화면을 탭하거나 드래그하면 키보드를 자동으로 내리는 Modifier입니다
struct KeyboardDismissModifier: ViewModifier {
    var dismissOnDrag: Bool = true

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissKeyboard()
                }
                .gesture(
                    dismissOnDrag ? DragGesture().onChanged { _ in dismissKeyboard() } : nil
                )
                .overlay(content)
        }
    }

    /// 키보드를 내리는 함수
    private func dismissKeyboard() {
        guard let window = UIApplication.shared
            .connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first else { return }

        window.endEditing(true)
    }
}

/// `View`에 `.keyboardDismissOnTap()`을 추가할 수 있도록 Extension 
extension View {
    func keyboardDismissOnTap(dismissOnDrag: Bool = false) -> some View {
        self.modifier(KeyboardDismissModifier(dismissOnDrag: dismissOnDrag))
    }
}
