//
//  Font+DesignSystem.swift
//  DesignSystem
//
//  Created by 박민서 on 1/12/25.
//  Copyright © 2025 yapp25-app2team. All rights reserved.
//

import SwiftUI

/// 앱에서 사용할 폰트와 스타일을 관리
public struct Typography {
    
    /// Pretendard 폰트의 굵기와 커스텀 폰트를 생성
    public struct Pretendard {
        /// Pretendard 폰트의 굵기(enum) 정의
        public enum Weight {
            case thin, extraLight, light, regular, medium, semibold, bold, extrabold, black

            public var fontConvertible: DesignSystemFontConvertible {
                switch self {
                    
                case .thin: return DesignSystemFontFamily.Pretendard.thin
                case .extraLight: return DesignSystemFontFamily.Pretendard.extraLight
                case .light: return DesignSystemFontFamily.Pretendard.light
                case .regular: return DesignSystemFontFamily.Pretendard.regular
                case .medium: return DesignSystemFontFamily.Pretendard.medium
                case .semibold: return DesignSystemFontFamily.Pretendard.semiBold
                case .bold: return DesignSystemFontFamily.Pretendard.bold
                case .extrabold: return DesignSystemFontFamily.Pretendard.extraBold
                case .black: return DesignSystemFontFamily.Pretendard.black
                }
            }
        }
    }
    
    /// 폰트, 줄 높이, 줄 간격, 자간 등을 포함한 스타일 정의를 위한 구조체입니다.
    public struct FontStyle {
        public let font: Font
        public let uiFont: UIFont
        public let size: CGFloat
        public let lineHeight: CGFloat
        public let lineSpacing: CGFloat
        public let letterSpacing: CGFloat
        
        /// 주어진 Weight, 크기, 줄 높이 배율, 자간으로 FontStyle을 생성합니다.
        /// - Parameters:
        ///   - weight: Pretendard 폰트의 굵기
        ///   - size: 폰트 크기
        ///   - lineHeightMultiplier: 줄 높이 배율 (CGFloat)
        ///   - letterSpacing: 자간 (CGFloat)
        init(_ weight: Pretendard.Weight, size: CGFloat, lineHeightMultiplier: CGFloat, letterSpacingRate: CGFloat) {
            self.font = weight.fontConvertible.swiftUIFont(size: size)
            self.uiFont = weight.fontConvertible.font(size: size)
            self.size = size
            self.lineHeight = size * lineHeightMultiplier
            self.lineSpacing = (size * lineHeightMultiplier) - size
            self.letterSpacing = size * letterSpacingRate
        }
    }
}

/// 앱에서 사용할 기본적인 폰트 스타일을 정의합니다.
public extension Typography.FontStyle {
    // Heading Styles
    static let heading1: Typography.FontStyle = Typography.FontStyle(.bold, size: 28, lineHeightMultiplier: 1.4, letterSpacingRate: -0.02)
    static let heading2: Typography.FontStyle = Typography.FontStyle(.bold, size: 24, lineHeightMultiplier: 1.5, letterSpacingRate: -0.02)
    static let heading3: Typography.FontStyle = Typography.FontStyle(.bold, size: 20, lineHeightMultiplier: 1.5, letterSpacingRate: -0.02)
    static let heading4: Typography.FontStyle = Typography.FontStyle(.bold, size: 18, lineHeightMultiplier: 1.5, letterSpacingRate: -0.02)
    
    // Body Styles
    static let body1Bold: Typography.FontStyle = Typography.FontStyle(.bold, size: 16, lineHeightMultiplier: 1.5, letterSpacingRate: -0.02)
    static let body1Semibold: Typography.FontStyle = Typography.FontStyle(.semibold, size: 16, lineHeightMultiplier: 1.5, letterSpacingRate: -0.02)
    static let body1Medium: Typography.FontStyle = Typography.FontStyle(.medium, size: 16, lineHeightMultiplier: 1.6, letterSpacingRate: -0.02)
    static let body2Bold: Typography.FontStyle = Typography.FontStyle(.bold, size: 15, lineHeightMultiplier: 1.5, letterSpacingRate: -0.02)
    static let body2Medium: Typography.FontStyle = Typography.FontStyle(.medium, size: 15, lineHeightMultiplier: 1.5, letterSpacingRate: -0.02)
    
    // Label Styles
    static let label1Bold: Typography.FontStyle = Typography.FontStyle(.bold, size: 13, lineHeightMultiplier: 1.3, letterSpacingRate: -0.02)
    static let label1Medium: Typography.FontStyle = Typography.FontStyle(.medium, size: 13, lineHeightMultiplier: 1.5, letterSpacingRate: -0.02)
    static let label2Bold: Typography.FontStyle = Typography.FontStyle(.bold, size: 12, lineHeightMultiplier: 1.5, letterSpacingRate: -0.02)
    static let label2Medium: Typography.FontStyle = Typography.FontStyle(.medium, size: 12, lineHeightMultiplier: 1.5, letterSpacingRate: -0.02)
    
    // Caption Styles
    static let caption1: Typography.FontStyle = Typography.FontStyle(.medium, size: 11, lineHeightMultiplier: 1.3, letterSpacingRate: -0.02)
}

/// 텍스트에 Typography 스타일과 색상을 적용하는 ViewModifier입니다.
/// Typography.FontStyle을 사용하여 폰트, 줄 간격, 자간 등을 설정하고,
/// Color를 통해 텍스트의 색상을 지정합니다.
struct TypographyModifier: ViewModifier {
    let style: Typography.FontStyle
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(style.font)
            .lineSpacing(style.lineSpacing)
            .kerning(style.letterSpacing)
            .foregroundStyle(color)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            if proxy.size.height < style.lineHeight {
                                applySingleLineFix(content: content)
                            }
                        }
                }
            )
    }
    
    /// 한 줄짜리 텍스트에 대한 lineHeight 적용
    @ViewBuilder
    private func applySingleLineFix(content: Content) -> some View {
        content
            .frame(height: style.lineHeight)
            .baselineOffset((style.lineHeight - style.size) / 2)
    }
}

/// Typography.FontStyle을 쉽게 적용할 수 있도록 도와줍니다.
/// Typography.FontStyle과 Color를 사용하여 폰트, 줄 간격, 자간, 텍스트 색상을 설정합니다.
public extension View {
    /// View에 Typography.FontStyle과 색상을 적용합니다.
    ///
    /// - Parameters:
    ///   - style: 적용할 Typography.FontStyle (폰트, 줄 간격, 자간 등 포함)
    ///   - color: 텍스트 색상 (기본값: .neutral950)
    /// - Returns: Typography 스타일과 색상이 적용된 View
    func typographyStyle(_ style: Typography.FontStyle, with color: Color = .neutral950) -> some View {
        self.modifier(TypographyModifier(style: style, color: color))
    }
}
