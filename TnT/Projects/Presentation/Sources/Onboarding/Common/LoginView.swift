//
//  LoginView.swift
//  Presentation
//
//  Created by 박서연 on 1/24/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

import DesignSystem

@ViewAction(for: LoginFeature.self)
public struct LoginView: View {
    @Bindable public var store: StoreOf<LoginFeature>
    
    public init(store: StoreOf<LoginFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            Header()
            
            VStack {
                Spacer()
                Image(.imgOnboardingLogin)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 310, height: 310)
                Spacer()
            }
            
            Bottom()
        }
        .padding(.horizontal, 28)
        .navigationBarBackButtonHidden()
        .navigationPopGestureDisabled()
        .sheet(item: $store.scope(state: \.termFeature, action: \.subFeature.termAction)) { store in
            TermView(store: store)
                .padding(.top, 24)
                .presentationDetents([.height(512)])
                .presentationDragIndicator(.visible)
        }
    }
    
    @ViewBuilder
    private func Header() -> some View {
        Spacer().frame(height: 48)
        VStack(spacing: 12) {
            Text("만나서 반가워요!")
                .typographyStyle(.body1Medium, with: .neutral500)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("트레이너와 트레이니\n케미 터트리기")
                .typographyStyle(.heading1, with: .neutral950)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    private func Bottom() -> some View {
        VStack(spacing: 8) {
            ForEach(LoginType.allCases, id: \.self) { type in
                HStack(spacing: 4) {
                    Image(type.image)
                        .resizable()
                        .frame(width: type.size, height: type.size)
                    Text(type.title)
                        .typographyStyle(.body1Medium, with: type.textColor)
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(type.background)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    switch type {
                    case .apple:
                        send(.tappedAppleLogin)
                    case .kakao:
                        send(.tappedKakaoLogin)
                    }
                }
                .debounce()
            }
        }
        .padding(.bottom, 62)
    }
}

public enum LoginType: String, CaseIterable {
    case apple
    case kakao
    
    var title: String {
        switch self {
        case .kakao:
            return "카카오로 계속하기"
        case .apple:
            return "애플로 계속하기"
        }
    }
    
    var image: ImageResource {
        switch self {
        case .kakao:
            return .icnKakao
        case .apple:
            return .icnApple
        }
    }
    
    var background: Color {
        switch self {
        case .kakao:
            return Color(hex: "FDE500")
        case .apple:
            return .neutral900
        }
    }
    
    var textColor: Color {
        switch self {
        case .kakao:
            return .neutral900
        case .apple:
            return .common0
        }
    }
    
    var size: CGFloat {
        switch self {
        case .kakao, .apple:
            return 24
        }
    }
}
