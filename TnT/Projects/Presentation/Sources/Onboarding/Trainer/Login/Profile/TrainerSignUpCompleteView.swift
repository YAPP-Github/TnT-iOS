//
//  TrainerProfileCompleteView.swift
//  Presentation
//
//  Created by 박서연 on 1/24/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import DesignSystem

@ViewAction(for: TrainerSignUpCompleteFeature.self)
public struct TrainerSignUpCompleteView: View {
    public let store: StoreOf<TrainerSignUpCompleteFeature>
    
    public init(store: StoreOf<TrainerSignUpCompleteFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            Header()
            
            profileImage()
            
            Spacer()
            
            TBottomButton(title: "시작하기", isEnable: true) {
                send(.startButtonTapped)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationPopGestureDisabled()
    }
    
    @ViewBuilder
    private func Header() -> some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 80.5)
            
            Text("만나서 반가워요\n김헬짱 트레이너님!")
                .typographyStyle(.heading1, with: .neutral950)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Text("트레이니와 함께\n케미를 터뜨려보세요! 🧨")
                .multilineTextAlignment(.center)
            
            Spacer().frame(height: 18)
        }
    }
    
    @ViewBuilder
    private func profileImage() -> some View {
        Image(.imgDefaultTrainerImage)
            .resizable()
            .frame(width: 200, height: 200)
            .clipShape(Circle())
    }
}
