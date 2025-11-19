//
//  TraineeMainFlowView.swift
//  Presentation
//
//  Created by 박민서 on 2/5/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import DesignSystem

public struct TraineeMainFlowView: View {
    @Bindable public var store: StoreOf<TraineeMainFlowFeature>

    public init(store: StoreOf<TraineeMainFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            EmptyView()
        } destination: { store in
            switch store.case {
                // MARK: MainTab
            case .mainTab(let store):
                TraineeMainTabView(store: store)
                
                // MARK: Home
            case .alarmCheck(let store):
                AlarmCheckView(store: store)
            case .addDietRecordPage(let store):
                TraineeAddDietRecordView(store: store)
            case .dietRecordDetail(let store):
                TraineeDietRecordDetailView(store: store)
                
                // MARK: MyPage
            case .traineeInvitationCodeInput(let store):
                TraineeInvitationCodeInputView(store: store)
            case .traineeTrainingInfoInput(let store):
                TraineeTrainingInfoInputView(store: store)
            case .traineeConnectionComplete(let store):
                TraineeConnectionCompleteView(store: store)
            case .traineeEditMypage(let store):
                TraineeEditMyPageView(store: store)
            }
        }
    }
}
