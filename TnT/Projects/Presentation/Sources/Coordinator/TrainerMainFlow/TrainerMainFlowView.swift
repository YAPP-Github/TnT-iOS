//
//  TrainerMainFlowView.swift
//  Presentation
//
//  Created by 박민서 on 2/5/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import DesignSystem

public struct TrainerMainFlowView: View {
    @Bindable public var store: StoreOf<TrainerMainFlowFeature>

    public init(store: StoreOf<TrainerMainFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            EmptyView()
        } destination: { store in
            switch store.case {
                // MARK: MainTab
            case .mainTab(let store):
                TrainerMainTabView(store: store)
            case .addPTSession(let store):
                TrainerAddPTSessionView(store: store)

                // MARK: Home
            case .alarmCheck(let store):
                AlarmCheckView(store: store)
            case .connectionComplete(let store):
                ConnectionCompleteView(store: store)
            case .connectedTraineeProfile(let store):
                ConnectedTraineeProfileView(store: store)
            case .checkInvitationCode(let store):
                CheckTrainerInvitationCodeView(store: store)
            
                // MARK: - TraineeList
            case .addTrainee(let store):
                AddTraineeView(store: store)
                
                // MARK: MyPage
            case .trainerMakeInvitationCodePage(let store):
                MakeInvitationCodeView(store: store)
            case .trainerMyPageEdit(let store):
                TrainerMyPageEditView(store: store)
            }
        }
    }
}
