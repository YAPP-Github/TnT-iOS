//
//  SocialLoginRepository.swift
//  Domain
//
//  Created by 박민서 on 1/26/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation

/// SNSLoginManager의 인터페이스 프로토콜입니다.
public protocol SocialLoginRepository {
    /// 애플 로그인을 수행합니다
    func appleLogin() async -> AppleLoginInfo?
    /// 카카오 로그인을 수행합니다
    func kakaoLogin() async -> KakaoLoginInfo?
    /// FCM 토큰을 가져옵니다
    func getFCMToken() async throws -> String
}
