//
//  ConnectionCompleteFeature.swift
//  Presentation
//
//  Created by 박서연 on 1/24/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation
import ComposableArchitecture

import Domain

@Reducer
public struct ConnectionCompleteFeature {
    @ObservableState
    public struct State: Equatable {
        /// 연결 여부
        @Shared(.appStorage(AppStorage.isConnected)) var isConnected: Bool = true
        var traineeId: Int64?
        var trainerId: Int64?
        var connectionInfo: ConnectionInfoEntity?
        var traineeProfile: ConnectedTraineeProfileEntity?
        
        public init(
            traineeId: Int64? = nil,
            trainerId: Int64? = nil,
            connectionInfo: ConnectionInfoEntity? = nil,
            traineeProfile: ConnectedTraineeProfileEntity? = nil
        ) {
            self.traineeId = traineeId
            self.trainerId = trainerId
            self.connectionInfo = connectionInfo
            self.traineeProfile = traineeProfile
        }
    }
    
    @Dependency(\.trainerRepoUseCase) private var trainerRepoUseCase
    
    public enum Action: Sendable, ViewAction {
        case view(View)
        case api(APIAction)
        case setNavigating(ConnectedTraineeProfileEntity)
        case setTraineeProfile(ConnectedTraineeProfileEntity)
        case setConnectionInfo(ConnectionInfoEntity)
        
        @CasePathable
        public enum View: Sendable {
            case tappedNextButton
            case onAppear
        }
        
        @CasePathable
        public enum APIAction: Sendable {
            case getConnectedTraineeInfo
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(let action):
                switch action {
                case .tappedNextButton:
                    guard let profile = state.traineeProfile else { return .none }
                    return .send(.setNavigating(profile))
                    
                case .onAppear:
                    state.$isConnected.withLock { $0 = true }
                    return .send(.api(.getConnectedTraineeInfo))
                }
                
            case .api(let action):
                switch action {
                case .getConnectedTraineeInfo:
                    guard let trainerId = state.trainerId, let traineeId = state.traineeId else { return .none }
                    return .run { send in
                        let result = try await trainerRepoUseCase.getConnectedTraineeInfo(trainerId: trainerId, traineeId: traineeId)
                        
                        let profile: ConnectedTraineeProfileEntity = result.trainee.toEntity()
                        let connectionInfo: ConnectionInfoEntity = result.toEntity()
                        
                        await send(.setConnectionInfo(connectionInfo))
                        await send(.setTraineeProfile(profile))
                    }
                }
                
            case .setTraineeProfile(let profile):
                state.traineeProfile = profile
                return .none
                
            case .setConnectionInfo(let connectionInfo):
                state.connectionInfo = connectionInfo
                return .none
                
            case .setNavigating:
                return .none
            }
        }
    }
}
