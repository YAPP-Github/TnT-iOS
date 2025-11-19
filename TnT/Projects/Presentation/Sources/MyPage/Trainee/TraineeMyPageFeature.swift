//
//  TraineeMyPageFeature.swift
//  Presentation
//
//  Created by 박민서 on 2/3/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation
import ComposableArchitecture

import Domain
import DesignSystem
import UserNotifications
import UIKit

extension SharedKey where Self == InMemoryKey<TraineeMyPageEntity> {
    static public var trainee: Self {
        inMemory("trainee")
    }
}

@Reducer
public struct TraineeMyPageFeature {
    
    public typealias FocusField = TraineeBasicInfoInputView.Field
    
    @ObservableState
    public struct State: Equatable {
        // MARK: Data related state
        /// 3일 동안 보지 않기 시작 날짜
        @Shared(.appStorage(AppStorage.hideHomePopupUntil)) var hidePopupUntil: Date?
        /// 트레이너 연결 여부
        @Shared(.appStorage(AppStorage.isConnected)) var isConnected: Bool = false
        /// 사용자 정보
        @Shared(.trainee) var traineeData = .init()

        /// 사용자 이름
        var userName: String
        /// 사용자 이미지 URL
        var userImageUrl: String?
        /// 앱 푸시 알림 허용 여부
        var appPushNotificationAllowed: Bool
        /// 버전 정보
        var versionInfo: String
        /// 트레이너 이름
        var trainerName: String
        
        // MARK: UI related state
        /// 트레이너 연결 여부
        var view_isTrainerConnected: Bool {
            return self.isConnected
        }
        /// 표시되는 팝업
        var view_popUp: PopUp?
        /// 팝업 표시 여부
        var view_isPopUpPresented: Bool
        
        /// `TraineeMyPageFeature.State`의 생성자
        /// - Parameters:
        ///   - userName: 사용자 이름 (기본값: `""`)
        ///   - userImageUrl: 사용자 프로필 이미지 URL (기본값: `nil`)
        ///   - appPushNotificationAllowed: 앱 푸시 알림 허용 여부 (기본값: `false`)
        ///   - versionInfo: 현재 앱 버전 정보 (기본값: `""`)
        ///   - trainerName: 트레이너 이름, 공백이 아닌 경우 연결된 것으로 표시(기본값: `""`)
        ///   - view_popUp: 현재 표시되는 팝업 (기본값: `nil`)
        ///   - view_isPopUpPresented: 팝업이 표시 중인지 여부 (기본값: `false`)
        public init(
            userName: String = "",
            userImageUrl: String? = nil,
            appPushNotificationAllowed: Bool = false,
            versionInfo: String = "",
            trainerName: String = "",
            view_popUp: PopUp? = nil,
            view_isPopUpPresented: Bool = false
        ) {
            self.userName = userName
            self.userImageUrl = userImageUrl
            self.appPushNotificationAllowed = appPushNotificationAllowed
            self.versionInfo = versionInfo
            self.trainerName = trainerName
            self.view_popUp = view_popUp
            self.view_isPopUpPresented = view_isPopUpPresented
        }
    }
    
    @Dependency(\.userUseCase) private var userUseCase: UserUseCase
    @Dependency(\.userUseRepoCase) private var userUseRepoCase: UserRepository
    @Dependency(\.keyChainManager) private var keyChainManager
    
    public enum Action: Sendable, ViewAction {
        /// 뷰에서 발생한 액션을 처리합니다.
        case view(View)
        /// API 콜 액션 처리
        case api(APIAction)
        /// 푸시 알람 허용 여부 설정
        case setAppPushNotificationAllowed(Bool)
        /// 푸시 알람 허용 시스템 화면 이동
        case sendAppPushNotificationSetting
        /// 마이페이지 정보 반영
        case setMyPageInfo(TraineeMyPageEntity)
        /// 팝업 세팅 처리
        case setPopUpStatus(PopUp?)
        /// 네비게이션 여부 설정
        case setNavigating(RoutingScreen)
        
        @CasePathable
        public enum View: Sendable, BindableAction {
            /// 바인딩할 액션을 처리
            case binding(BindingAction<State>)
            /// 개인정보 수정 버튼 탭
            case tapEditProfileButton
            /// 트레이너와 연결하기 버튼 탭
            case tapConnectTrainerButton
            /// 서비스 이용약관 버튼 탭
            case tapTOSButton
            /// 개인정보 처리방침 버튼 탭
            case tapPrivacyPolicyButton
            /// 오픈소스 라이선스 버튼 탭
            case tapOpenSourceLicenseButton
            /// 트레이너와 연결끊기 버튼 탭
            case tapDisconnectTrainerButton
            /// 로그아웃 버튼 탭
            case tapLogoutButton
            /// 계정 탈퇴 버튼 탭
            case tapWithdrawButton
            /// 팝업 좌측 secondary 버튼 탭
            case tapPopUpSecondaryButton(popUp: PopUp?)
            /// 팝업 우측 primary 버튼 탭
            case tapPopUpPrimaryButton(popUp: PopUp?)
            /// 표시될 때
            case onAppear
        }
        
        @CasePathable
        public enum APIAction: Sendable {
            /// 로그아웃 API
            case logout
            /// 회원 탈퇴 API
            case withdraw
            /// 마이페이지 정보 get API
            case myPageInfo
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        Reduce { state, action in
            switch action {
            case .view(let action):
                switch action {
                case .binding(\.appPushNotificationAllowed):
                    return self.getAppPushNotificationAllowed(state: &state, tryToggle: true)
                    
                case .binding:
                    return .none
                    
                case .tapEditProfileButton:
                    return .send(.setNavigating(.traineeInfoEdit))
                    
                case .tapConnectTrainerButton:
                    return .send(.setNavigating(.traineeInvitationCodeInput))
                    
                case .tapTOSButton:
                    if let url = URL(string: AppLinks.termsOfService) {
                        UIApplication.shared.open(url)
                    }
                    return .none
                    
                case .tapPrivacyPolicyButton:
                    if let url = URL(string: AppLinks.privacyPolicy) {
                        UIApplication.shared.open(url)
                    }
                    return .none
                    
                case .tapOpenSourceLicenseButton:
                    if let url = URL(string: AppLinks.openSourceLicense) {
                        UIApplication.shared.open(url)
                    }
                    return .none
                    
                case .tapDisconnectTrainerButton:
                    return .send(.setPopUpStatus(.disconnectTrainer(trainerName: state.trainerName)))
                    
                case .tapLogoutButton:
                    return .send(.setPopUpStatus(.logout))
                    
                case .tapWithdrawButton:
                    return .send(.setPopUpStatus(.withdraw))
                    
                case .tapPopUpSecondaryButton(let popUp):
                    guard popUp != nil else { return .none }
                    return .send(.setPopUpStatus(nil))
                    
                case .tapPopUpPrimaryButton(let popUp):
                    guard let popUp else { return .none }
                    switch popUp {
                    case .disconnectTrainer:
                        return .send(.setPopUpStatus(popUp.nextPopUp))
                        
                    case .logout:
                        return .send(.api(.logout))
                        
                    case .withdraw:
                        return .send(.api(.withdraw))
                        
                    case .disconnectCompleted:
                        return .send(.setPopUpStatus(nil))
                        
                    case .logoutCompleted, .withdrawCompleted:
                        state.$hidePopupUntil.withLock { $0 = nil }
                        state.$isConnected.withLock { $0 = false }
                        return .concatenate(
                            .send(.setPopUpStatus(nil)),
                            .send(.setNavigating(.onboardingLogin))
                        )
                    }
                    
                case .onAppear:
                    return .merge(
                        self.getAppPushNotificationAllowed(state: &state, tryToggle: false),
                        .send(.api(.myPageInfo))
                    )
                }
                
            case .api(let action):
                switch action {
                case .logout:
                    return .run { send in
                        let result = try await userUseRepoCase.postLogout()
                        try keyChainManager.delete(.sessionId)
                        await send(.setPopUpStatus(.logoutCompleted))
                    }
                    
                case .withdraw:
                    return .run { send in
                        let result = try await userUseRepoCase.postWithdrawal()
                        try keyChainManager.delete(.sessionId)
                        await send(.setPopUpStatus(.withdrawCompleted))
                    }
                    
                case .myPageInfo:
                    return .run { send in
                        let result = try await userUseRepoCase.getMyPageInfo()
                        let info: TraineeMyPageEntity = result.toEntity()
                        await send(.setMyPageInfo(info))
                    }
                }
            
            case .setMyPageInfo(let myPageInfo):
                state.$isConnected.withLock { $0 = myPageInfo.isConnected }
                state.userName = myPageInfo.name
                state.userImageUrl = myPageInfo.profileImageUrl
                state.$traineeData.withLock { $0 = myPageInfo }
                print("😀 state.traineeData \(state.traineeData)")
                return .none
            
            case .setPopUpStatus(let popUp):
                state.view_popUp = popUp
                state.view_isPopUpPresented = popUp != nil
                return .none
                
            case .setAppPushNotificationAllowed(let isAllowed):
                state.appPushNotificationAllowed = isAllowed
                return .none
                
            case .sendAppPushNotificationSetting:
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                return .none
                
            case .setNavigating:
                return .none
            }
        }
    }
}

extension TraineeMyPageFeature {
    func getAppPushNotificationAllowed(state: inout State, tryToggle: Bool) -> Effect<Action> {
        return .run { send in
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            let isAllowed = (settings.authorizationStatus == .authorized)
            if tryToggle {
                await send(.sendAppPushNotificationSetting)
            } else {
                await send(.setAppPushNotificationAllowed(isAllowed))
            }
        }
    }
}

extension TraineeMyPageFeature {
    /// 본 화면에서 라우팅(파생)되는 화면
    public enum RoutingScreen: Sendable {
        /// 트레이니 정보 수정 페이지
        case traineeInfoEdit
        /// 초대코드 입력 페이지
        case traineeInvitationCodeInput
        /// 초기 로그인 페이지
        case onboardingLogin
    }
}

public extension TraineeMyPageFeature {
    /// 본 화면에 팝업으로 표시되는 목록
    enum PopUp: Equatable, Sendable {
        /// 트레이너와 연결을 해제할까요?
        case disconnectTrainer(trainerName: String)
        /// 트레이너와 연결이 해제되었어요
        case disconnectCompleted(trainerName: String)
        /// 현재 계정을 로그아웃 할까요?
        case logout
        /// 로그아웃이 완료되었어요
        case logoutCompleted
        /// 계정을 탈퇴할까요?
        case withdraw
        /// 계정 탈퇴가 완료되었어요
        case withdrawCompleted
        
        var nextPopUp: PopUp? {
            switch self {
            case .disconnectTrainer(let name):
                return .disconnectCompleted(trainerName: name)
            case .logout:
                return .logoutCompleted
            case .withdraw:
                return .withdrawCompleted
            case .disconnectCompleted, .logoutCompleted, .withdrawCompleted:
                return nil
            }
        }
        
        var title: String {
            switch self {
            case .disconnectTrainer(let name):
                return "\(name) 트레이너와 연결을 해제할까요?"
            case .disconnectCompleted(let name):
                return "\(name) 트레이너와 연결이 해제되었어요"
            case .logout:
                return  "현재 계정을 로그아웃 할까요?"
            case .logoutCompleted:
                return "로그아웃이 완료되었어요"
            case .withdraw:
                return "계정을 탈퇴할까요?"
            case .withdrawCompleted:
                return "계정 탈퇴가 완료되었어요"
            }
        }
        
        var message: String {
            switch self {
            case .disconnectTrainer:
                return "힘께 나눴던 기록들이 사라져요"
            case .disconnectCompleted:
                return "더 폭발적인 케미로 다시 만나요!"
            case .logout, .logoutCompleted:
                return "언제든지 다시 로그인 할 수 있어요!"
            case .withdraw:
                return "운동 및 식단 기록에 대한 데이터가 사라져요!"
            case .withdrawCompleted:
                return "다음에 더 폭발적인 케미로 다시 만나요! 💣"
            }
        }
        
        var showAlertIcon: Bool {
            switch self {
            case .disconnectTrainer, .logout, .withdraw:
                return true
            case .disconnectCompleted, .logoutCompleted, .withdrawCompleted:
                return false
            }
        }
        
        var secondaryAction: Action.View? {
            switch self {
            case .disconnectTrainer, .logout, .withdraw:
                return .tapPopUpSecondaryButton(popUp: self)
            case .disconnectCompleted, .logoutCompleted, .withdrawCompleted:
                return nil
            }
        }
        
        var primaryAction: Action.View {
            return .tapPopUpPrimaryButton(popUp: self)
        }
    }
}
