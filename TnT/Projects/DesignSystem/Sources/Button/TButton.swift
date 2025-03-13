//
//  TButton.swift
//  DesignSystem
//
//  Created by 박서연 on 1/15/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI

public enum ButtonPostiton {
    case right
    case left
    case both
}

/// TnT 앱 내에서 전반적으로 사용되는 커스텀 버튼(텍스트+옵셔널 이미지) 컴포넌트입니다
public struct TButton: View {
    /// 버튼의 상태 (default 또는 disable 상태)
    public let state: ButtonState
    
    /// 버튼의 크기 및 스타일 구성
    public let config: ButtonConfiguration
    
    /// 버튼의 제목
    public let title: String
    
    /// 버튼에 표시될 이미지 속성
    public let image: ButtonImage?
    
    /// 버튼 탭 시 수행할 동작 (옵셔널)
    public var action: (() -> Void)
    
    /// TButton의 초기화 메서드
    /// - Parameters:
    ///   - state: 버튼의 상태
    ///   - config: 버튼 구성 (크기, 글꼴 등)
    ///   - title: 버튼 제목
    ///   - image: 버튼 이미지 (옵셔널)
    ///   - imageSize: 이미지 크기 (옵셔널)
    ///   - action: 버튼 탭 시 동작 (옵셔널)
    public init(
        title: String,
        config: ButtonConfiguration,
        state: ButtonState,
        image: ButtonImage? = nil,
        action: (@escaping () -> Void)
    ) {
        self.title = title
        self.config = config
        self.state = state
        self.image = image
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 4) {
                // 왼쪽 이미지 추가
                if let leftImage = image, leftImage.type == .left || leftImage.type == .both {
                    Image(leftImage.resource)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: leftImage.size, height: leftImage.size)
                }
                
                // 제목 추가
                Text(title)
                    .typographyStyle(config.font, with: textColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(minHeight: config.font.lineHeight)
                
                // 오른쪽 이미지 추가
                if let rightImage = image, rightImage.type == .right || rightImage.type == .both {
                    Image(rightImage.resource)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: rightImage.size, height: rightImage.size)
                }
            }
            .padding(.vertical, config.verticalSize + 0.5)
            .padding(.horizontal, config.horizontalSize + 0.5)
            .background(
                RoundedRectangle(cornerRadius: config.radius)
                    .fill(backgroundColor)
                    .stroke(borderColor, lineWidth: 1.5)
            )
        }
    }
    
    /// 버튼의 배경색
    private var backgroundColor: Color {
        switch state {
        case .default(let style):
            return style.backgound
        case .disable(let style):
            return style.backgound
        }
    }
    
    /// 버튼의 텍스트 색상
    private var textColor: Color {
        switch state {
        case .default(let style):
            return style.textColor
        case .disable(let style):
            return style.textColor
        }
    }
    
    /// 버튼의 외곽선 색상
    private var borderColor: Color {
        switch state {
        case .default(let style):
            return style.borderColor
        case .disable(let style):
            return style.borderColor
        }
    }
}

public extension TButton {
    /// 버튼의 상태를 정의하는 열거형
    /// - `default`: 기본 스타일 상태
    /// - `disable`: 비활성화 상태
    enum ButtonState {
        case `default`(DefaultStyle)
        case disable(DefaultStyle)
    }

    /// 기본 스타일을 정의하는 열거형
    /// 버튼의 다양한 기본 스타일과 그에 따른 색상 속성을 정의
    enum DefaultStyle {
        case primary(isEnabled: Bool)
        case gray(isEnabled: Bool)
        case outline(isEnabled: Bool)
        case red(isEnabled: Bool)
        
        /// 버튼 배경 색상
        var backgound: Color {
            switch self {
            case .primary(let isEnabled):
                return isEnabled ? .neutral900 : .neutral200
            case .gray(let isEnabled):
                return isEnabled ? .neutral100 : .neutral200
            case .outline(let isEnabled):
                return isEnabled ? .clear : .clear
            case .red(let isEnabled):
                return isEnabled ? .red50 : .clear
            }
        }
        
        /// 버튼 텍스트 색상
        var textColor: Color {
            switch self {
            case .primary(let isEnabled):
                return isEnabled ? .neutral50 : .neutral50
            case .gray(let isEnabled):
                return isEnabled ? .neutral500 : .neutral50
            case .outline(let isEnabled):
                return isEnabled ? .neutral500 : .neutral300
            case .red(let isEnabled):
                return isEnabled ? .red600 : .neutral300
            }
        }
        
        /// 버튼 외곽선 색상
        var borderColor: Color {
            switch self {
            case .primary(let isEnabled):
                return isEnabled ? .clear : .clear
            case .gray(let isEnabled):
                return isEnabled ? .clear : .clear
            case .outline(let isEnabled):
                return isEnabled ? .neutral300 : .neutral300
            case .red(let isEnabled):
                return isEnabled ? .red400 : .neutral300
            }
        }
    }

    /// 버튼의 크기별 구성 속성을 정의하는 열거형
    /// 버튼의 코너 반경, 세로 크기, 글꼴 스타일을 정의
    enum ButtonConfiguration {
        case xLarge
        case large
        case medium
        case small
        case xSmall
        
        /// 버튼 코너 반경 (radius)
        var radius: CGFloat {
            switch self {
            case .xLarge, .large:
                return 16
            case .medium:
                return 12
            case .small:
                return 8
            case .xSmall:
                return 6
            }
        }
        
        /// 버튼 세로 크기 (vertical padding)
        var verticalSize: CGFloat {
            switch self {
            case .xLarge:
                return 20
            case .large:
                return 16
            case .medium:
                return 12
            case .small:
                return 7
            case .xSmall:
                return 3
            }
        }
        
        var horizontalSize: CGFloat {
            switch self {
            case .xLarge, .large, .medium:
                return 20
            case .small:
                return 12
            case .xSmall:
                return 8
            }
        }
        
        /// 버튼 글꼴 스타일
        var font: Typography.FontStyle {
            switch self {
            case .xLarge:
                return .body1Semibold
            case .large, .medium:
                return .body1Medium
            case .small:
                return .label2Medium
            case .xSmall:
                return .label2Medium
            }
        }
    }
}
