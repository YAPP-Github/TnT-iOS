//
//  PostSocailEntity.swift
//  Domain
//
//  Created by 박서연 on 1/31/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation

public enum SocialType: String, Sendable {
    case kakao = "KAKAO"
    case apple = "APPLE"
}

/// 소셜 로그인 요청 DTO
public struct PostSocialEntity: Equatable, Sendable {
    /// 소셜 로그인 타입 (KAKAO, APPLE)
    public let socialType: SocialType
    /// FCM 토큰
    public var fcmToken: String
    /// 소셜 액세스 토큰
    public let socialAccessToken: String?
    /// 애플 ID 토큰 (Apple z로그인 시 필요)
    public let idToken: String?
    
    public init(
        socialType: SocialType,
        fcmToken: String,
        socialAccessToken: String? = nil,
        idToken: String? = nil
    ) {
        self.socialType = socialType
        self.fcmToken = fcmToken
        self.socialAccessToken = socialAccessToken
        self.idToken = idToken
    }
}

/// 소셜 로그인 응답 DTO
public struct PostSocialLoginResEntity: Equatable {
    /// 세션 ID
    public let sessionId: String?
    /// 소셜 로그인 ID
    public let socialId: String?
    /// 소셜 이메일
    public let socialEmail: String?
    /// 소셜 로그인 타입 (KAKAO, APPLE)
    public let socialType: String?
    /// 가입 여부 (`true`: 이미 가입됨, `false`: 미가입)
    public let isSignUp: Bool
    /// 멤버타입
    public let membertype: MemberTypeResDTO
}
