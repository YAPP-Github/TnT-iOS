//
//  TraineeConnectionCompleteFeature.swift
//  Presentation
//
//  Created by 박민서 on 1/28/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation
import ComposableArchitecture

import Domain

/// 트레이너-트레이니 연결 후 프로필을 표시하는 리듀서
@Reducer
public struct TraineeConnectionCompleteFeature {
    
    @ObservableState
    public struct State: Equatable {
        // MARK: Data related state
        /// 연결 여부
        @Shared(.appStorage(AppStorage.isConnected)) var isConnected: Bool = true
        /// 현재 사용자 유저 타입 (트레이너/트레이니)
        var userType: UserType
        /// 트레이니 사용자 이름
        var traineeName: String
        /// 트레이니 프로필 이미지 URL
        var traineeImageURL: String?
        /// 트레이너 사용자 이름
        var trainerName: String
        /// 트레이너 프로필 이미지 URL
        var trainerImageURL: String?
        
        // MARK: UI related state
        var view_myName: String {
            return userType == .trainee ? traineeName : trainerName
        }
        var view_myImageURL: String? {
            return userType == .trainee ? traineeImageURL : trainerImageURL
        }
        /// 상대방 사용자 유형 (트레이너 → 트레이니, 트레이니 → 트레이너)
        var view_opponentUserType: UserType {
            return userType == .trainer ? .trainee : .trainer
        }
        /// 상대방 사용자 이름
        var view_opponentUserName: String {
            return userType == .trainer ? traineeName : trainerName
        }
        /// 상대방 프로필 이미지 URL
        var view_opponentUserImageURL: String? {
            return userType == .trainer ? traineeImageURL : trainerImageURL
        }
        
        /// `TraineeProfileCompletionFeature.State`의 생성자
        /// - Parameters:
        public init(
            userType: UserType,
            traineeName: String,
            traineeImageURL: String? = nil,
            trainerName: String,
            trainerImageURL: String? = nil
        ) {
            self.userType = userType
            self.traineeName = traineeName
            self.traineeImageURL = traineeImageURL
            self.trainerName = trainerName
            self.trainerImageURL = trainerImageURL
        }
    }
    
    public enum Action: Sendable, ViewAction {
        /// 뷰에서 발생한 액션을 처리합니다.
        case view(View)
        /// 네비게이션 여부 설정
        case setNavigating
        
        @CasePathable
        public enum View: Sendable, BindableAction {
            /// 바인딩할 액션을 처리
            case binding(BindingAction<State>)
            /// "다음으로" 버튼이 눌렸을 때
            case tapNextButton
            /// 화면이 표시되었을 때
            case onAppear
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        Reduce { state, action in
            switch action {
            case .view(let action):
                switch action {
                case .binding:
                    return .none
                    
                case .tapNextButton:
                    return .send(.setNavigating)
                
                case .onAppear:
                    state.$isConnected.withLock { $0 = true }
                    return .none
                }

            case .setNavigating:
                return .none
            }
        }
    }
}
