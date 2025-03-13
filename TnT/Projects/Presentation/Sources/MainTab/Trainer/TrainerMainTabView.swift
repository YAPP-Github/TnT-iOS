//
//  TrainerMainTabView.swift
//  Presentation
//
//  Created by 박민서 on 2/4/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import DesignSystem

@ViewAction(for: TrainerMainTabFeature.self)
public struct TrainerMainTabView: View {
    @Bindable public var store: StoreOf<TrainerMainTabFeature>

    public init(store: StoreOf<TrainerMainTabFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            switch store.state {
            case .home:
                if let store = store.scope(state: \.home, action: \.subFeature.homeAction) {
                    TrainerHomeView(store: store)
                }
            case .feedback:
                if let store = store.scope(state: \.feedback, action: \.subFeature.feedbackAction) {
                    TrainerFeedbackView(store: store)
                }
            case .traineeList:
                if let store = store.scope(state: \.traineeList, action: \.subFeature.traineeListAction) {
                    TrainerManagementView(store: store)
                }
            case .myPage:
                if let store = store.scope(state: \.myPage, action: \.subFeature.myPageAction) {
                    TrainerMypageView(store: store)
                }
            }
            
            BottomTabBar()
        }
        .navigationPopGestureDisabled()
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    // MARK: Section
    @ViewBuilder
    private func BottomTabBar() -> some View {
        HStack(alignment: .top) {
            ForEach(TrainerTabInfo.allCases, id: \.hashValue) { tab in
                TMainTabButton(
                    unselectedIcon: tab.emptyIcn,
                    selectedIcon: tab.filledIcn,
                    text: tab.rawValue,
                    isSelected: store.state.tabInfo == tab,
                    action: { send(.selectTab(tab)) }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(height: 54 + .safeAreaBottom)
        .padding(.horizontal, 24)
        .background(Color.white.shadow(radius: 5).opacity(0.5))
        .overlay(
            Group {
                if store.isPopupActive {
                    Color.black.opacity(0.5)
                        .transition(.opacity)
                }
            }
        )
        .animation(.easeInOut, value: store.isPopupActive)
    }
}
