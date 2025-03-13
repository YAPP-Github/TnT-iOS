//
//  SocialLogInRepositoryImpl.swift
//  Data
//
//  Created by 박서연 on 1/29/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation
import Dependencies

import Domain

public enum LoginError: Error {
    case invalidCredentials
    case networkFailure
    case kakaoError
    case appleError
    case fcmError
    case unknown(message: String)
}

public struct SocialLogInRepositoryImpl: SocialLoginRepository {
    
    public let loginManager: SNSLoginManager
    
    public init(loginManager: SNSLoginManager) {
        self.loginManager = loginManager
    }

    public func appleLogin() async -> AppleLoginInfo? {
        return await loginManager.appleLogin()
    }
    
    public func kakaoLogin() async -> KakaoLoginInfo? {
        return await loginManager.kakaoLogin()
    }
    
    public func getFCMToken() async throws -> String {
        return try await loginManager.getFCMToken()
    }
}
