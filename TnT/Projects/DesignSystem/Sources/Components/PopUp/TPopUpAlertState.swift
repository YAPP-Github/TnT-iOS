//
//  TPopupAlertState.swift
//  DesignSystem
//
//  Created by 박민서 on 1/15/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI

/// TPopUpAlertView에 표시하는 정보입니다.
/// 팝업의 제목, 메시지, 버튼 정보를 포함.
public struct TPopupAlertState: Equatable {
    /// 팝업 제목
    public var title: String
    /// 팝업 메시지 (옵션)
    public var message: String?
    /// 팝업의 경고 아이콘 표시 (옵션)
    public var showAlertIcon: Bool
    /// 팝업에 표시할 커스텀 아이콘 (옵션)
    public var icon: PopupIcon?
    /// 팝업에 표시될 버튼 배열
    public var buttons: [ButtonState]
    
    /// TPopupAlertState 초기화 메서드
    /// - Parameters:
    ///   - title: 팝업의 제목
    ///   - message: 팝업의 메시지 (선택 사항, 기본값: `nil`)
    ///   - showAlertIcon: 팝업의 경고 아이콘 표시 (기본값: `false`)
    ///   - icon: 팝업에 표시할 커스텀 아이콘 (기본값: `nil`)
    ///   - buttons: 팝업에 표시할 버튼 배열 (기본값: 빈 배열)
    public init(
        title: String,
        message: String? = nil,
        showAlertIcon: Bool = false,
        icon: PopupIcon? = nil,
        buttons: [ButtonState] = []
    ) {
        self.title = title
        self.message = message
        self.showAlertIcon = showAlertIcon
        self.icon = icon
        self.buttons = buttons
    }
}

public extension TPopupAlertState {
    enum PopupIcon {
        case warning
        case checkMarkLightGreen
        case questionMark
        
        var imageResource: ImageResource {
            switch self {
            case .warning:
                return .icnWarning
            case .checkMarkLightGreen:
                return .icnCheckMarkLightGreen
            case .questionMark:
                return .icnQuestionMark
            }
        }
    }
}

public extension TPopupAlertState {
    // TODO: 버튼 컴포넌트 완성 시 수정
    /// TPopUpAlertView.AlertButton에 표시하는 정보입니다.
    struct ButtonState: Equatable {
        /// 버튼 제목
        public let title: String
        /// 버튼 스타일
        public let style: Style
        /// 버튼 클릭 시 동작
        public let action: EquatableClosure
        
        public enum Style {
            case primary
            case secondary
        }
        
        /// TPopupAlertState.ButtonState 초기화 메서드
        /// - Parameters:
        ///   - title: 버튼 제목
        ///   - style: 버튼 스타일 (기본값: `.primary`)
        ///   - action: 버튼 클릭 시 동작
        public init(
            title: String,
            style: Style = .primary,
            action: EquatableClosure
        ) {
            self.action = action
            self.title = title
            self.style = style
        }
    }
}
