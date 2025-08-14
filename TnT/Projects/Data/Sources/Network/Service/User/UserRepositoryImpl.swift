//
//  UserRepositoryImpl.swift
//  Data
//
//  Created by 박민서 on 1/25/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation
import Dependencies

import Domain

/// 사용자 관련 네트워크 요청을 처리하는 UserRepository 구현체
public struct UserRepositoryImpl: UserRepository {
    private let networkService: NetworkService = .shared
    
    public init() {}
    
    /// 로그인 세션 유효 체크 요청을 수행
    public func getSessionCheck() async throws -> GetSessionCheckResDTO {
        return try await networkService.request(UserTargetType.getSessionCheck, decodingType: GetSessionCheckResDTO.self)
    }
    
    /// 소셜 로그인 요청을 수행
    public func postSocialLogin(_ reqDTO: PostSocialLoginReqDTO) async throws -> PostSocialLoginResDTO {
        return try await networkService.request(
            UserTargetType.postSocialLogin(reqDTO: reqDTO),
            decodingType: PostSocialLoginResDTO.self
        )
    }
    
    /// 회원가입 요청을 수행
    public func postSignUp(_ reqDTO: PostSignUpReqDTO, profileImage: Data?) async throws -> PostSignUpResDTO {
        return try await networkService.request(
            UserTargetType.postSignUp(
                reqDTO: reqDTO,
                imgData: profileImage
            ),
            decodingType: PostSignUpResDTO.self
        )
    }
    
    /// 로그아웃 요청을 수행
    public func postLogout() async throws -> PostLogoutResDTO {
        return try await networkService.request(UserTargetType.postLogout, decodingType: PostLogoutResDTO.self)
    }
    
    /// 회원탈퇴 요청을 수행
    public func postWithdrawal() async throws -> PostWithdrawalResDTO {
        return try await networkService.request(UserTargetType.postWithdrawal, decodingType: PostWithdrawalResDTO.self)
    }
    
    /// 마이페이지 요청을 수행
    public func getMyPageInfo() async throws -> GetMyPageInfoResDTO {
        return try await networkService.request(UserTargetType.getMyPageInfo, decodingType: GetMyPageInfoResDTO.self)
    }
    
    ///  내 정보 수정 요청을 수행
    public func putMyInfo(_ reqDTO: PutMyInfoReqDTO, profileImage: Data?) async throws -> EmptyResponse {
        return try await networkService.request(
            UserTargetType.putMyInfo(
                reqDTO: reqDTO,
                imgData: profileImage
            ),
            decodingType: EmptyResponse.self
        )
    }
}
