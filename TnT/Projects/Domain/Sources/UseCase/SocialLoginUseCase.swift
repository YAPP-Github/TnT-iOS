//
//  SocialLoginUseCase.swift
//  Domain
//
//  Created by 박서연 on 1/29/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation

public struct SocialLoginUseCase {

    private let socialLoginRepository: SocialLoginRepository
    
    public init(socialLoginRepository: SocialLoginRepository) {
        self.socialLoginRepository = socialLoginRepository
    }
    
    public func appleLogin() async -> AppleLoginInfo? {
        return await socialLoginRepository.appleLogin()
    }
    
    public func kakaoLogin() async -> KakaoLoginInfo? {
        return await socialLoginRepository.kakaoLogin()
    }
    
    public func getFCMToken() async throws -> String {
        return try await socialLoginRepository.getFCMToken()
    }
}
