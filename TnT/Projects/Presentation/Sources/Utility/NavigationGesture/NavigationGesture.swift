//
//  NavigationGesture.swift
//  Presentation
//
//  Created by 박서연 on 2/13/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension UINavigationController: @retroactive ObservableObject, @retroactive UIGestureRecognizerDelegate {
    /// 현재 제스처 비활성화된 화면의 수를 추적하는 카운터
    static var gestureDisabledCount: Int = 0
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return UINavigationController.gestureDisabledCount == 0
    }
}

struct PopGestureModifier: ViewModifier {
    let disabled: Bool
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard disabled else { return }
                UINavigationController.gestureDisabledCount += 1
            }
            .onDisappear {
                guard disabled else { return }
                UINavigationController.gestureDisabledCount -= 1
            }
    }
}

extension View {
    /// 뷰가 실제 화면에 보일 때만 pop 제스처가 비활성화되고, 화면에서 사라지면 자동으로 제스처가 다시 활성화됩니다.
    func navigationPopGestureDisabled(_ disabled: Bool = true) -> some View {
        self.modifier(PopGestureModifier(disabled: disabled))
    }
}
