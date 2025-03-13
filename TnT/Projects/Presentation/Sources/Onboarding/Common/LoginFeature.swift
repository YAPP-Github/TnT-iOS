//
//  LoginFeature.swift
//  Presentation
//
//  Created by 박서연 on 1/24/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

import Domain
import DIContainer
import Data

@Reducer
public struct LoginFeature {
    @ObservableState
    public struct State: Equatable {
        public var userType: UserType?
        public var nickname: String?
        public var socialType: LoginType?
        public var socialEmail: String?
        public var postUserEntity: PostSocialEntity?
        public var termState: Bool = false
        public var fcmToken: String?
        @Shared var signUpEntity: PostSignUpEntity
        @Presents var termFeature: TermFeature.State?
        
        public init(
            signUpEntity: Shared<PostSignUpEntity>,
            postUserEntity: PostSocialEntity? = nil
        ) {
            self._signUpEntity = signUpEntity
            self.postUserEntity = postUserEntity
        }
    }
    
    @Dependency(\.userUseCase) private var userUseCase: UserUseCase
    @Dependency(\.userUseRepoCase) private var userUseCaseRepo: UserRepository
    @Dependency(\.socialLogInUseCase) private var socialLoginUseCase: SocialLoginUseCase
    @Dependency(\.keyChainManager) var keyChainManager: KeyChainManager
    
    public enum Action: ViewAction {
        /// 뷰에서 일어나는 액션을 처리합니다.(카카오,애플로그인 실행)
        case view(View)
        /// api 액션처리
        case api(APIAction)
        /// 하위 화면에서 일어나는 액션을 처리합니다
        case subFeature(SubFeatureAction)
        /// 네비게이션 여부 설정
        case setNavigating(RoutingScreen)
        /// signUpEntity를 소셜로그인 정보로 업데이트
        case updateSignUpEntityWithSocialInfo(res: PostSocialLoginResDTO)
        /// 약관 동의 화면 표시
        case showTermView
        
        @CasePathable
        public enum View: Equatable {
            case tappedAppleLogin
            case tappedKakaoLogin
        }
        
        @CasePathable
        public enum APIAction: Sendable {
            /// FCM 토큰 받아 주입
            case insertFCMToken(entity: PostSocialEntity)
            /// 소셜 로그인 post 요청
            case postSocialLogin(entity: PostSocialEntity)
        }
        
        @CasePathable
        public enum SubFeatureAction: Equatable {
            /// 역관 동의 화면에서 발생하는 액션 처리
            case termAction(PresentationAction<TermFeature.Action>)
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(view):
                switch view {
                case .tappedAppleLogin:
                    return .run { @Sendable send in
                        guard let result = await socialLoginUseCase.appleLogin() else { return }
                        let fcmToken: String? = try keyChainManager.read(for: .apns)
                        
                        /// 서버 <-> 소셜 로그인을 위한 객체 생성
                        let entity: PostSocialEntity = PostSocialEntity(
                            socialType: .apple,
                            fcmToken: fcmToken ?? "",
                            socialAccessToken: "",
                            idToken: result.identityToken
                        )
                        
                        await send(.api(.insertFCMToken(entity: entity)))
                    }
                    
                case .tappedKakaoLogin:
                    return .run { @Sendable send in
                        guard let result = await socialLoginUseCase.kakaoLogin() else { return }
                        let fcmToken: String? = try keyChainManager.read(for: .apns)
                        
                        /// 서버 <-> 소셜 로그인을 위한 객체 생성
                        let entity: PostSocialEntity = PostSocialEntity(
                            socialType: .kakao,
                            fcmToken: fcmToken ?? "",
                            socialAccessToken: result.accessToken,
                            idToken: ""
                        )
                        
                        await send(.api(.insertFCMToken(entity: entity)))
                    }
                }
                
            case .api(let action):
                switch action {
                case .insertFCMToken(let entity):
                    return .run { send in
                        var mutatedEntity = entity
                        if let fcmToken = try? await socialLoginUseCase.getFCMToken() {
                            mutatedEntity.fcmToken = fcmToken
                            await send(.api(.postSocialLogin(entity: mutatedEntity)))
                        } else {
                            let fcmToken: String? = try? keyChainManager.read(for: .apns)
                            mutatedEntity.fcmToken = fcmToken ?? ""
                            await send(.api(.postSocialLogin(entity: mutatedEntity)))
                        }
                    }
                    
                case .postSocialLogin(let entity):
                    let post: PostSocialLoginReqDTO = entity.toDTO()
                    
                    return .run { send in
                        let result: PostSocialLoginResDTO = try await userUseCaseRepo.postSocialLogin(post)
                        saveSessionId(result.sessionId)
                        
                        switch result.memberType {
                        case .trainer:
                            await send(.setNavigating(.trainerHome))
                        case .trainee:
                            await send(.setNavigating(.traineeHome))
                        case .unregistered:
                            await send(.updateSignUpEntityWithSocialInfo(res: result))
                        case .unknown:
                            print("unknown 타입이에요 토스트해줏요")
                        }
                    }
                }
                
            case .subFeature(.termAction(.presented(.setNavigating))):
                state.termFeature = nil
                state.$signUpEntity.withLock { $0.collectionAgreement = true }
                state.$signUpEntity.withLock { $0.serviceAgreement = true }
                state.$signUpEntity.withLock { $0.advertisementAgreement = true }
                return .send(.setNavigating(.userTypeSelection))
            
            case .subFeature(.termAction(.dismiss)):
                state.termFeature = nil
                return .none
                
            case .subFeature:
                return .none
                
            case .updateSignUpEntityWithSocialInfo(let res):
                guard let socialType = SocialType(rawValue: res.socialType ?? "") else { return .none }
                state.$signUpEntity.withLock { $0.socialId = res.socialId }
                state.$signUpEntity.withLock { $0.socialEmail = res.socialEmail }
                state.$signUpEntity.withLock { $0.socialType = socialType }
                return .send(.showTermView)
                
            case .showTermView:
                state.termFeature = .init()
                return .none
                
            case .setNavigating:
                return .none
            }
        }
        .ifLet(\.termFeature, action: \.subFeature.termAction.presented) {
            TermFeature()
        }
    }
}

extension LoginFeature {
    private func saveSessionId(_ sessionId: String?) {
        guard let sessionId else { return }
        do {
            try keyChainManager.save(sessionId, for: .sessionId)
        } catch {
            print("로그인 정보 저장 싪패")
        }
    }
}

extension LoginFeature {
    /// 본 화면에서 라우팅(파생)되는 화면
    public enum RoutingScreen {
        case traineeHome
        case trainerHome
        case userTypeSelection
    }
}
