//
//  TPopUpAlertView.swift
//  DesignSystem
//
//  Created by 박민서 on 1/16/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI

/// 팝업 Alert의 콘텐츠 뷰
/// 타이틀, 메시지, 버튼 섹션으로 구성.
public struct TPopUpAlertView: View {
    /// 팝업 상태 정보
    private let alertState: TPopupAlertState
    
    /// - Parameter alertState: 팝업에 표시할 상태 정보
    public init(alertState: TPopupAlertState) {
        self.alertState = alertState
    }

    public var body: some View {
        VStack(spacing: 20) {
            // 텍스트 Section
            VStack(spacing: 8) {
                VStack(spacing: 0) {
                    if alertState.showAlertIcon {
                        Image(.icnWarning)
                            .resizable()
                            .frame(width: 80, height: 80)
                    } else {
                        Color.clear
                            .frame(height: 20)
                    }
                    Text(alertState.title)
                        .typographyStyle(.heading3, with: .neutral900)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                if let message = alertState.message {
                    Text(message)
                        .typographyStyle(.body2Medium, with: .neutral500)
                        .multilineTextAlignment(.center)
                }
            }
            
            // 버튼 Section
            HStack {
                ForEach(alertState.buttons, id: \.title) { buttonState in
                    buttonState.toButton()
                }
            }
        }
    }
}

public extension TPopUpAlertView {
    // TODO: 버튼 컴포넌트 완성 시 수정
    struct AlertButton: View {
        let title: String
        let style: TPopupAlertState.ButtonState.Style
        let action: () -> Void
        
        public init(
            title: String,
            style: TPopupAlertState.ButtonState.Style,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.style = style
            self.action = action
        }
        
        public var body: some View {
            Button(action: action) {
                Text(title)
                    .typographyStyle(.body1Medium, with: style == .primary ? Color.neutral50 : Color.neutral500)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(style == .primary ? Color.neutral900 : Color.neutral100)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}

public extension TPopupAlertState.ButtonState {
    /// `ButtonState`를 `AlertButton`으로 변환
    func toButton() -> TPopUpAlertView.AlertButton {
        TPopUpAlertView.AlertButton(
            title: self.title,
            style: self.style,
            action: self.action.execute
        )
    }
}
