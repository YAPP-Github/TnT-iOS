//
//  TrainerMypageFeature.swift
//  Presentation
//
//  Created by 박서연 on 2/4/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import Domain
import DesignSystem

@Reducer
public struct TrainerMypageFeature {
    
    @ObservableState
    public struct State: Equatable {
        /// 3일 동안 보지 않기 시작 날짜
        @Shared(.appStorage(AppStorage.hideHomePopupUntil)) var hidePopupUntil: Date?
        /// 트레이니 연결 여부
        @Shared(.appStorage(AppStorage.isConnected)) var isConnected: Bool = false
        /// 사용자 이름
        var userName: String
        /// 사용자 이미지 URL
        var userImageUrl: String?
        /// 관리 중인 회원
        var studentCount: Int
        /// 함께 했던 회원
        var oldStudentCount: Int
        /// 앱 푸시 알림 허용 여부
        var appPushNotificationAllowed: Bool
        /// 버전 정보
        var versionInfo: String
        /// 팝업
        var view_popUp: PopUp?
        /// 팝업 표시 유무
        var view_isPopUpPresented: Bool = false
        
        public init(
            userName: String = "",
            userImageUrl: String? = nil,
            studentCount: Int = 0,
            oldStudentCount: Int = 0,
            appPushNotificationAllowed: Bool = false,
            versionInfo: String = "",
            view_popUp: PopUp? = nil,
            view_isPopUpPresented: Bool = false
        ) {
            self.userName = userName
            self.userImageUrl = userImageUrl
            self.studentCount = studentCount
            self.oldStudentCount = oldStudentCount
            self.appPushNotificationAllowed = appPushNotificationAllowed
            self.versionInfo = versionInfo
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
        case setMyPageInfo(TrainerMyPageEntity)
        /// 팝업 세팅 처리
        case setPopUpStatus(PopUp?)
        /// 네비게이션 여부 설정
        case setNavigating(RoutingScreen)
        
        @CasePathable
        public enum View: Sendable, BindableAction {
            /// 바인딩할 액션을 처리 (알람)
            case binding(BindingAction<State>)
            /// 서비스 이용약관 버튼 탭
            case tapTOSButton
            /// 개인정보 처리방침 버튼 탭
            case tapPrivacyPolicyButton
            /// 오픈소스 라이선스 버튼 탭
            case tapOpenSourceLicenseButton
            /// 로그아웃 버튼 탭
            case tapLogoutButton
            /// 계정 탈퇴 버튼 탭
            case tapWithdrawButton
            /// 팝업 왼쪽 탭
            case tapPupUpSecondaryButton(popUp: PopUp?)
            /// 팝옵 오른쪽 탭
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
    
    public init() { }
    
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
                    
                case .tapLogoutButton:
                    return .send(.setPopUpStatus(.logout))
                    
                case .tapWithdrawButton:
                    return .send(.setPopUpStatus(.withdraw))
                    
                case .tapPupUpSecondaryButton(let popUp):
                    guard popUp != nil else { return .none }
                    return .send(.setPopUpStatus(nil))
                    
                case .tapPopUpPrimaryButton(let popUp):
                    guard let popUp else { return .none }
                    switch popUp {
                    case .logout:
                        return .send(.api(.logout))
                        
                    case .withdraw:
                        return .send(.api(.withdraw))
                        
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
                        let info: TrainerMyPageEntity = result.toEntity()
                        await send(.setMyPageInfo(info))
                    }
                }
                
            case .setMyPageInfo(let myPageInfo):
                state.userName = myPageInfo.name
                state.userImageUrl = myPageInfo.profileImageUrl
                if let activeCount = myPageInfo.activeTraineeCount, let totalCount = myPageInfo.totalTraineeCount {
                    state.studentCount = activeCount
                    state.oldStudentCount = totalCount
                }
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

extension TrainerMypageFeature {
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

extension TrainerMypageFeature {
    /// 본 화면에서 라우팅(파생)되는 화면
    public enum RoutingScreen: Sendable {
        /// 초기 로그인 페이지
        case onboardingLogin
    }
}

public extension TrainerMypageFeature {
    /// 트레이너 마이페이지 팝업
    enum PopUp: Equatable, Sendable {
        /// 로그아웃
        case logout
        /// 로그아웃 완료
        case logoutCompleted
        /// 회원 탈퇴
        case withdraw
        /// 회원 탈퇴 완료
        case withdrawCompleted
        
        var nextPopUp: PopUp? {
            switch self {
            case .logout:
                return .logoutCompleted
            case .withdraw:
                return .withdrawCompleted
            case .logoutCompleted, .withdrawCompleted:
                return nil
            }
        }
        
        var title: String {
            switch self {
            case .logout:
                return "현재 계정을 로그아웃 할까요?"
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
            case .logout:
                return "언제든지 다시 로그인 할 수 있어요!"
            case .logoutCompleted:
                return "언제든지 다시 로그인 할 수 있어요!"
            case .withdraw:
                return "함께 했던 회원들에 대한 데이터가 사라져요!"
            case .withdrawCompleted:
                return "다음에 더 폭발적인 케미로 다시 만나요! 💣"
            }
        }
        
        var alertIcon: Bool {
            switch self {
            case .logout, .withdraw:
                return true
                
            case .logoutCompleted, .withdrawCompleted:
                return false
            }
        }
        
        var secondaryAction: Action.View? {
            switch self {
            case .logout, .withdraw:
                return .tapPupUpSecondaryButton(popUp: self)
            case .logoutCompleted, .withdrawCompleted:
                return nil
            }
        }
        
        var primaryAction: Action.View {
            return .tapPopUpPrimaryButton(popUp: self)
        }
    }
}
