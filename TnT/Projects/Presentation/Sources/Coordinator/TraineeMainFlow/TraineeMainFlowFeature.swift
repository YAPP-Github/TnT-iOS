//
//  TraineeMainFlowFeature.swift
//  Presentation
//
//  Created by 박민서 on 2/5/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import Domain

@Reducer
public struct TraineeMainFlowFeature {
    @ObservableState
    public struct State: Equatable {
        public var path: StackState<Path.State>
        
        public init(path: StackState<Path.State> = .init([.mainTab(.home(.init()))])) {
            self.path = path
        }
    }

    public enum Action: Sendable {
        /// 현재 표시되고 있는 path 화면 내부에서 일어나는 액션을 처리합니다.
        case path(StackActionOf<Path>)
        /// Flow 변경을 AppCoordinator로 전달합니다
        case switchFlow(AppFlow)
        case onAppear
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case let .path(action):
                switch action {
                    /// 트레이니 탭뷰의 네비 관련 액션 처리
                case .element(_, action: .mainTab(.setNavigating(let screen))):
                    switch screen {
                        /// 트레이니 홈
                    case .traineeHome(let screen):
                        switch screen {
                            /// 홈 화면 알림 버튼 탭 -> 알림 화면 이동
                        case .alarmPage:
                            state.path.append(.alarmCheck(.init(userType: .trainee)))
                            return .none
                        case .sessionRecordPage:
                            return .none
                        case .recordFeedbackPage:
                            return .none
                        case .addWorkoutRecordPage:
                            return .none
                        case .addDietRecordPage(let date):
                            state.path.append(.addDietRecordPage(.init(calendarSelectedDate: date)))
                            return .none
                        case .traineeInvitationCodeInput:
                            state.path.append(.traineeInvitationCodeInput(.init(view_navigationType: .existingUser)))
                            return .none
                        case .dietDetailPage(let id):
                            state.path.append(.dietRecordDetail(.init(dietId: id)))
                            return .none
                        }
                        /// 트레이니 마이페이지
                    case .traineeMyPage(let screen):
                        switch screen {
                        case .traineeInfoEdit:
                            return .none
                            
                            /// 마이페이지 초대코드 입력하기 버튼 탭-> 초대코드 입력 화면 이동
                        case .traineeInvitationCodeInput:
                            state.path.append(.traineeInvitationCodeInput(.init(view_navigationType: .existingUser)))
                            return .none
                            
                            /// 마이페이지 로그아웃/회원탈퇴 -> 온보딩 로그인 화면 이동
                        case .onboardingLogin:
                            return .send(.switchFlow(.onboardingFlow(.init())))
                        }
                    }
                    
                    /// 알림 목록 특정 알림 탭 -> 해당 알림 내용 화면 이동
                case .element(_, action: .alarmCheck(.setNavigating)):
                    // 특정 화면 append
                    return .none
                    
                    /// 식단 기록 화면 등록 -> 홈화면으로 이동
                case .element(id: _, action: .addDietRecordPage(.setNavigating)):
                    state.path.removeSubrange(1...)
                    return .none
                    
                    /// 마이페이지 초대코드 입력화면 다음 버튼 탭 - > PT 정보 입력 화면 or 홈 이동
                case .element(_, action: .traineeInvitationCodeInput(.setNavigating(let screen))):
                    switch screen {
                    case .traineeHome:
                        state.path.removeSubrange(1...)
                    case let .trainingInfoInput(trainerName, invitationCode):
                        state.path.append(.traineeTrainingInfoInput(.init(trainerName: trainerName, invitationCode: invitationCode)))
                    }
                    return .none
                    
                    /// PT 정보 입력 화면 다음 버튼 탭 -> 연결 완료 화면 이동
                case let .element(id: _, action: .traineeTrainingInfoInput(.setNavigating(.connectionComplete(trainerName, traineeName, trainerImageUrl, traineeImageUrl)))):
                    state.path.append(
                        .traineeConnectionComplete(
                            .init(
                                userType: .trainee,
                                traineeName: traineeName,
                                traineeImageURL: traineeImageUrl,
                                trainerName: trainerName,
                                trainerImageURL: trainerImageUrl
                            )
                        )
                    )
                    return .none
                    
                    /// 연결 완료 화면 -> 홈으로 이동
                case .element(id: _, action: .traineeConnectionComplete(.setNavigating)):
                    state.path.removeSubrange(1...)
                    return .none
                    
                default:
                    return .none
                }
                
            case .switchFlow:
                return .none
                
            case .onAppear:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        
    }
}

extension TraineeMainFlowFeature {
    @Reducer(state: .equatable, .sendable)
    public enum Path {
        // MARK: MainTab
        /// 트레이니 메인탭 - 홈/마이페이지
        case mainTab(TraineeMainTabFeature)
        
        // MARK: Home
        /// 알림 목록
        case alarmCheck(AlarmCheckFeature)
        /// 식단 기록 추가
        case addDietRecordPage(TraineeAddDietRecordFeature)
        /// 식단 상세 화면
        case dietRecordDetail(TraineeDietRecordDetailFeature)
        
        // MARK: MyPage
        /// 트레이니 초대 코드입력
        case traineeInvitationCodeInput(TraineeInvitationCodeInputFeature)
        /// 트레이니 수업 정보 입력
        case traineeTrainingInfoInput(TraineeTrainingInfoInputFeature)
        /// 트레이니-트레이너 연결 완료
        case traineeConnectionComplete(TraineeConnectionCompleteFeature)
    }
}
