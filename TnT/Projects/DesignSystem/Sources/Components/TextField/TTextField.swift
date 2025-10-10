//
//  TTextField.swift
//  DesignSystem
//
//  Created by 박민서 on 1/14/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI

/// TnT 앱 내에서 전반적으로 사용되는 커스텀 텍스트 필드 컴포넌트입니다.
public struct TTextField: View {
    
    /// 텍스트 필드 우측에 표시될 RightView
    private let rightView: RightView?
    /// Placeholder 텍스트
    private let placeholder: String
    
    /// 입력 텍스트
    @Binding private var text: String
    /// 텍스트 필드 상태
    @Binding private var status: Status
    /// 텍스트 컬러 상태
    @State private var textColor: Color = .neutral400
    /// 텍스트 필드 포커스 상태
    @FocusState var isFocused: Bool
    
    /// - Parameters:
    ///   - placeholder: Placeholder 텍스트 (기본값: "내용을 입력해주세요")
    ///   - text: 입력 텍스트 (Binding)
    ///   - textFieldStatus: 텍스트 필드 상태 (Binding)
    ///   - rightView: 텍스트 필드 우측에 표시될 `TTextField.RightView`를 정의하는 클로저.
    public init(
        placeholder: String = "내용을 입력해주세요",
        text: Binding<String>,
        textFieldStatus: Binding<Status>,
        @ViewBuilder rightView: () -> RightView? = { nil }
    ) {
        self.placeholder = placeholder
        self._text = text
        self._status = textFieldStatus
        self.rightView = rightView()
        self._textColor = .init(initialValue: textFieldStatus.wrappedValue.textColor(isFocused: false))
    }
    
    public var body: some View {
        // Text Field
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                TextField(placeholder, text: $text)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .font(Typography.FontStyle.body1Medium.font)
                    .lineSpacing(Typography.FontStyle.body1Medium.lineSpacing)
                    .kerning(Typography.FontStyle.body1Medium.letterSpacing)
                    .tint(Color.neutral800)
                    .foregroundStyle(textColor)
                    .padding(8)
                    .frame(height: 42)
                    .onChange(of: status) {
                        textColor = status.textColor(isFocused: isFocused)
                    }
                
                if let rightView {
                    rightView
                }
            }
            
            TDivider(color: status.underlineColor(isFocused: isFocused))
        }
    }
}

public extension TTextField.RightView {
    enum Style {
        case unit(text: String, status: TTextField.Status)
        case button(title: String, state: TButton.ButtonState, tapAction: () -> Void)
        case dropDown(tintColor: Color, tapAction: () -> Void)
    }
}

public extension TTextField {
    /// TextField 우측 컨텐츠 뷰입니다
    struct RightView: View {
        /// 컨텐츠 스타일
        private let style: RightView.Style
        
        public init(style: RightView.Style) {
            self.style = style
        }
        
        public var body: some View {
            
            switch style {
            case let .unit(text, status):
                Text(text)
                    .typographyStyle(.body1Medium, with: status.textColor(isFocused: true))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 3)
                
            case let .button(title, state, tapAction):
                TButton(
                    title: title,
                    config: .small,
                    state: state,
                    action: tapAction
                )
                .frame(width: 66)
                
            case let .dropDown(tintColor, tapAction):
                Button(action: tapAction) {
                    Image(.icnArrowDown)
                        .renderingMode(.template)
                        .resizable()
                        .tint(tintColor)
                        .frame(width: 32, height: 32)
                }
            }
        }
    }
    
    /// TextField 상단 헤더입니다
    struct Header: View {
        /// 필수 여부를 표시
        private let isRequired: Bool
        /// 헤더의 제목
        private let title: String
        /// 입력 가능한 글자 수 제한
        private let limitCount: Int?
        /// 입력된 텍스트 카운트
        private var textCount: Int?
        
        public init(
            isRequired: Bool,
            title: String,
            limitCount: Int?,
            textCount: Int?
        ) {
            self.isRequired = isRequired
            self.title = title
            self.limitCount = limitCount
            self.textCount = textCount
        }
        
        public var body: some View {
            HStack(spacing: 0) {
                Text(title)
                    .typographyStyle(.body1Bold, with: .neutral900)
                if isRequired {
                    Text("*")
                        .typographyStyle(.body1Bold, with: .red500)
                }
                
                Spacer()
                
                if let limitCount, let textCount {
                    Text("\(textCount)/\(limitCount)자")
                        .typographyStyle(.label1Medium, with: textCount > limitCount ? .red500 : .neutral400)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                }
            }
        }
    }
    
    /// TextField 하단 푸터입니다
    struct Footer: View {
        /// 푸터 텍스트
        private let footerText: String
        /// 텍스트 필드 상태
        private var status: Status
        
        public init(footerText: String, status: Status) {
            self.footerText = footerText
            self.status = status
        }
        
        public var body: some View {
            Text(footerText)
                .typographyStyle(.body2Medium, with: status.footerColor)
        }
    }
}

public extension TTextField {
    /// TextField에 표시되는 상태입니다
    enum Status: Equatable {
        case empty
        case filled
        case invalid
        case valid
        
        /// 밑선 색상 설정
        func underlineColor(isFocused: Bool) -> Color {
            switch self {
            case .empty, .filled:
                return isFocused ? .neutral600 : .neutral200
            case .invalid:
                return .red500
            case .valid:
                return .blue500
            }
        }
        
        /// 텍스트 색상 설정
        func textColor(isFocused: Bool) -> Color {
            switch self {
            case .empty:
                return .neutral400
            case .filled, .invalid, .valid:
                return .neutral600
            }
        }
        
        /// 푸터 색상 설정
        var footerColor: Color {
            switch self {
            case .empty, .filled:
                return .clear
            case .invalid:
                return .red500
            case .valid:
                return .blue500
            }
        }
    }
}

struct TTextFieldModifier: ViewModifier {
    /// Textfield 상단에 표시될 헤더
    private let header: TTextField.Header?
    /// Textfield 하단에 표시될 푸터
    private let footer: TTextField.Footer?
    
    public init(header: TTextField.Header?, footer: TTextField.Footer?) {
        self.header = header
        self.footer = footer
    }
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 헤더 추가
            if let header {
                header
            }
            
            // 본체(TextField)
            content
            
            // 푸터 추가
            if let footer {
                footer
            }
        }
    }
}

public extension TTextField {
    /// 헤더와 푸터를 포함한 레이아웃을 텍스트 필드에 적용합니다.
    ///
    /// - Parameters:
    ///   - header: `TTextField.Header`로 정의된 상단 헤더. (옵션)
    ///   - footer: `TTextField.Footer`로 정의된 하단 푸터. (옵션)
    /// - Returns: 헤더와 푸터가 포함된 새로운 View.
    func withSectionLayout(header: TTextField.Header? = nil, footer: TTextField.Footer? = nil) -> some View {
        self.modifier(TTextFieldModifier(header: header, footer: footer))
    }
}
