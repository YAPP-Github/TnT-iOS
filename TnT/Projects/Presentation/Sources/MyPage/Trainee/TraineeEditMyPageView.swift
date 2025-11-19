//
//  TraineeEditMyPageView.swift
//  Presentation
//
//  Created by 박서연 on 11/18/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import Domain
import DesignSystem

public struct TraineeEditMyPageView: View {
    
    public let store: StoreOf<TraineeEditMyPageViewReducer>
    
    public init(store: StoreOf<TraineeEditMyPageViewReducer>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Navigationbar
            
            ImageSection
            
        }
    }
}

private extension TraineeEditMyPageView {
    var Navigationbar: some View {
        TNavigation(
            type: .LButtonWithTitle(
                leftImage: .icnArrowLeft,
                centerTitle: "내 정보 수정"
            ),
            leftAction: { print("뒤로 가기") } // // 뒤로 가기
        )
    }
    
//    @ViewBuilder  CreateProfileFeature
//    private func ImageSection() -> some View {
//        Group {
//            if let imageData = store.userImageData,
//               let uiImage = UIImage(data: imageData) {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .scaledToFill()
//                    .clipShape(Circle())
//            } else {
//                Image(store.userType == .trainer
//                      ? .imgDefaultTrainerImage
//                      : .imgDefaultTraineeImage
//                )
//                .resizable()
//                .clipShape(Circle())
//            }
//        }
//        .frame(width: 132, height: 132)
//        .overlay(alignment: .bottomTrailing) {
//            PhotoPickerView(store: store.scope(
//                state: \.photoLibraryState,
//                action: \.subFeature.photoLibrary
//            ), selectedItem: $store.view_photoPickerItem) {
//                ZStack {
//                    Circle()
//                        .fill(Color.neutral900)
//                        
//                    Image(.icnWriteWhite)
//                        .resizable()
//                        .frame(width: 16, height: 16)
//                }
//            }
//            .frame(width: 28, height: 28)
//        }
//    }
}


import Foundation
import ComposableArchitecture

import Domain
import DesignSystem
import UserNotifications
import UIKit

@Reducer
public struct TraineeEditMyPageViewReducer {
    @ObservableState
    
    public struct State: Equatable {
        @Shared(.trainee) var traineeData = .init()
        
        // MARK: - 팝업 관련
        /// 표시되는 팝업
        var view_popUp: PopUp?
        /// 팝업 표시 여부
        var view_isPopUpPresented: Bool
    }
    
    public enum Action: Sendable, ViewAction {
        /// 뷰에서 발생한 액션을 처리합니다.
        case view(View)
        /// API 콜 액션 처리
        case api(APIAction)
        /// 팝업 세팅 처리
        case setPopUpStatus(PopUp?)
        
        @CasePathable
        public enum View: Sendable, BindableAction {
            /// 바인딩할 액션을 처리
            case binding(BindingAction<State>)
            /// 팝업 좌측 secondary 버튼 탭
            case tapPopUpSecondaryButton(popUp: PopUp?)
            /// 팝업 우측 primary 버튼 탭
            case tapPopUpPrimaryButton(popUp: PopUp?)
        }
        
        @CasePathable
        public enum APIAction: Sendable {
            /// 확인 버튼 탭 - 정보변경
            case tappedConfrimButton
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
                    
                case .tapPopUpSecondaryButton(let popUp):
                    guard popUp != nil else { return .none }
                    return .send(.setPopUpStatus(nil))
                case .tapPopUpPrimaryButton(let popUp):
                    guard let popUp else { return .none }
                    
                    switch popUp {
                    case .endToEditInfo:
                        return .none
                    }
                }
                
            case .api(let action):
                switch action {
                case .tappedConfrimButton:
                    return .none
                }
                
            case .setPopUpStatus(let popUp):
                state.view_popUp = popUp
                state.view_isPopUpPresented = popUp != nil
                return .none
            }
        }
    }
}

public extension TraineeEditMyPageViewReducer {
    /// 본 화면에 팝업으로 표시되는 목록
    enum PopUp: Equatable, Sendable {
        /// 정보 수정을 종료할까요?
        case endToEditInfo

        
        var title: String {
            switch self {
            case .endToEditInfo:
                "정보 수정을 종료할까요?"
            }
        }
        
        var message: String {
            switch self {
            case .endToEditInfo:
                "수정 사항이 저장되지 않아요!"
            }
        }
        
        var showAlertIcon: Bool {
            switch self {
            case .endToEditInfo:
                return true
            }
        }
        
        var secondaryAction: Action.View? {
            switch self {
            case .endToEditInfo:
                return .tapPopUpSecondaryButton(popUp: self)
            }
        }
        
        var primaryAction: Action.View {
            return .tapPopUpPrimaryButton(popUp: self)
        }
    }
}
