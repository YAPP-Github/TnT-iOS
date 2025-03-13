//
//  TrainerMainTabFeature.swift
//  Presentation
//
//  Created by 박민서 on 2/4/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

@Reducer
public struct TrainerMainTabFeature {
    @ObservableState
    public enum State: Equatable {
        case home(TrainerHomeFeature.State)
        case feedback(TrainerFeedbackFeature.State)
        case traineeList(TrainerManagementFeature.State)
        case myPage(TrainerMypageFeature.State)
        
        /// state case와 tabinfo 연결
        var tabInfo: TrainerTabInfo {
            switch self {
            case .home:
                return .home
            case .feedback:
                return .feedback
            case .traineeList:
                return .traineeList
            case .myPage:
                return .mypage
            }
        }
        
        /// 하위 Feature에서 팝업이 활성화되었는지 여부를 전달
        var isPopupActive: Bool {
            switch self {
            case .home(let homeState):
                return homeState.view_isPopUpPresented
            case .feedback:
                return false
            case .traineeList:
                return false
            case .myPage(let myPageState):
                return myPageState.view_isPopUpPresented
            }
        }
        
        public init() {
            self = .home(TrainerHomeFeature.State())
        }
    }

    public enum Action: Sendable, ViewAction {
        /// 뷰에서 일어나는 액션을 처리합니다.
        case view(View)
        /// 하위 화면에서 일어나는 액션을 처리합니다
        case subFeature(SubFeatureAction)
        /// 화면 네비게이션 설정
        case setNavigating(RoutingScreen)
        
        @CasePathable
        public enum View: Sendable {
            case selectTab(TrainerTabInfo)
        }
        
        @CasePathable
        public enum SubFeatureAction: Sendable {
            /// 홈 화면에서 발생하는 액션 처리
            case homeAction(TrainerHomeFeature.Action)
//            /// 피드백 화면에서 발생하는 액션 처리
            case feedbackAction(TrainerFeedbackFeature.Action)
            /// 회원 목록 화면에서 발생하는 액션 처리
            case traineeListAction(TrainerManagementFeature.Action)
            /// 마이페이지 화면에서 발생하는 액션 처리
            case myPageAction(TrainerMypageFeature.Action)
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(view):
                switch view {
                case .selectTab(let tab):
                    guard state.tabInfo != tab else { return .none }
                    switch tab {
                    case .home:
                        state = .home(.init())
                        return .none
                    case .feedback:
                        // TODO: feedback Feature 작성 후 추가해주세요
                        state = .feedback(.init())
                        return .none
                    case .traineeList:
                        state = .traineeList(.init())
                        return .none
                    case .mypage:
                        state = .myPage(.init())
                        return .none
                    }
                }

            case .subFeature(let internalAction):
                // TODO: Feature에 RoutingScreen 추가 후 추가해주세요
                switch internalAction {
                case .homeAction(.setNavigating(let screen)):
                    return .send(.setNavigating(.trainerHome(screen)))
                case .traineeListAction(.setNavigating(let screen)):
                    return .send(.setNavigating(.trainerTraineeList(screen)))
                case .myPageAction(.setNavigating(let screen)):
                    return .send(.setNavigating(.trainerMyPage(screen)))
                default:
                    return .none
                }
                
            case .setNavigating:
                return .none
            }
        }
        .ifCaseLet(\.home, action: \.subFeature.homeAction) {
            TrainerHomeFeature()
        }
        .ifCaseLet(\.traineeList, action: \.subFeature.traineeListAction, then: {
            TrainerManagementFeature()
        })
        .ifCaseLet(\.myPage, action: \.subFeature.myPageAction) {
            TrainerMypageFeature()
        }
    }
}

extension TrainerMainTabFeature {
    /// 하위 화면에서 파생되는 라우팅을 전달합니다
    // TODO: Feature에 RoutingScreen 추가 후 추가해주세요
    public enum RoutingScreen: Sendable {
        /// 트레이너 홈
        case trainerHome(TrainerHomeFeature.RoutingScreen)
//        /// 트레이너 피드백
//        case trainerFeedback
        /// 트레이너 회원 목록
        case trainerTraineeList(TrainerManagementFeature.RoutingScreen)
        /// 트레이너 마이페이지
        case trainerMyPage(TrainerMypageFeature.RoutingScreen)
    }
}
