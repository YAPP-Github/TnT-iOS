//
//  AutoSizingBottomSheetModifier.swift
//  DesignSystem
//
//  Created by 박민서 on 2/2/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI

/// 바텀시트의 높이를 자동 조정하는 ViewModifier
/// 내부 컨텐츠의 크기를 측정하여 적절한 높이를 설정합니다
struct AutoSizingBottomSheetModifier: ViewModifier {
    /// 바텀시트 상단의 그래버 표시
    let presentationDragIndicator: Visibility
    /// 측정된 컨텐츠의 높이 (초기값 300)
    @State private var contentHeight: CGFloat = 300

    init(presentationDragIndicator: Visibility = .visible) {
        self.presentationDragIndicator = presentationDragIndicator
    }

    func body(content: Content) -> some View {
        content
            .padding(.top, 24)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            contentHeight = proxy.size.height
                        }
                        .onChange(of: proxy.size.height) { _, newHeight in
                            contentHeight = newHeight
                        }
                }
            )
            .presentationDetents([.height(contentHeight)])
            .presentationDragIndicator(presentationDragIndicator)
    }
}

public extension View {
    /// 뷰에 자동 크기 조정 바텀시트를 적용하는 Modifier
    /// - Parameter presentationDragIndicator: 바텀시트 상단 Grabber의 가시성 설정 (기본값: .visible)
    /// - Returns: 자동 크기 조정 바텀시트가 적용된 뷰
    func autoSizingBottomSheet(presentationDragIndicator: Visibility = .visible) -> some View {
        self.modifier(AutoSizingBottomSheetModifier(presentationDragIndicator: presentationDragIndicator))
    }
}
