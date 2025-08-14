//
//  UserUseCase.swift
//  Domain
//
//  Created by 박민서 on 1/25/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Dependencies
import Foundation

// MARK: - UserUseCase 프로토콜
public protocol UserUseCase {
    /// 개별 필드 - 사용자 이름 검증
    func validateUserName(_ name: String) -> Bool
    /// 개별 필드 - 생년월일 검증
    func validateBirthDate(_ birthDate: String) -> Bool
    /// 개별 필드 - 키 검증
    func validateHeight(_ height: String) -> Bool
    /// 개별 필드 - 몸무게 검증
    func validateWeight(_ weight: String) -> Bool
    /// 개별 필드 - 주의사항 검증
    func validatePrecaution(_ text: String) -> Bool
    /// 이름 최대 길이 제한
    func getMaxNameLength() -> Int
    /// 주의사항 최대 길이 제한
    func getPrecautionMaxLength() -> Int
}

// MARK: - Default 구현체
public struct DefaultUserUseCase: UserUseCase {
    
    public let userRepostiory: UserRepository
    
    public init(userRepostiory: UserRepository) {
        self.userRepostiory = userRepostiory
    }
    
    // MARK: - Usecase
    public func validateUserName(_ name: String) -> Bool {
        return !name.isEmpty && UserPolicy.userNameInput.textValidation(name)
    }
    
    public func validateBirthDate(_ birthDate: String) -> Bool {
        return birthDate.isEmpty || UserPolicy.birthDateInput.textValidation(birthDate)
    }
    
    public func validateHeight(_ height: String) -> Bool {
        return !height.isEmpty && UserPolicy.heightInput.textValidation(height)
    }
    
    public func validateWeight(_ weight: String) -> Bool {
        return !weight.isEmpty && UserPolicy.weightInput.textValidation(weight)
    }
    
    public func validatePrecaution(_ text: String) -> Bool {
        return UserPolicy.precautionInput.textValidation(text)
    }
    
    public func getMaxNameLength() -> Int {
        return UserPolicy.maxNameLength
    }
    
    public func getPrecautionMaxLength() -> Int {
        return UserPolicy.maxPrecautionLength
    }
}

// MARK: - Repository
extension DefaultUserUseCase: UserRepository {
    public func getSessionCheck() async throws -> GetSessionCheckResDTO {
        return try await userRepostiory.getSessionCheck()
    }
    
    public func postSocialLogin(_ reqDTO: PostSocialLoginReqDTO) async throws -> PostSocialLoginResDTO {
        return try await userRepostiory.postSocialLogin(reqDTO)
    }

    public func postSignUp(_ reqDTO: PostSignUpReqDTO, profileImage: Data?) async throws -> PostSignUpResDTO {
        return try await userRepostiory.postSignUp(reqDTO, profileImage: profileImage)
    }
    
    public func postLogout() async throws -> PostLogoutResDTO {
        return try await userRepostiory.postLogout()
    }
    
    public func postWithdrawal() async throws -> PostWithdrawalResDTO {
        return try await userRepostiory.postWithdrawal()
    }
    
    public func getMyPageInfo() async throws -> GetMyPageInfoResDTO {
        return try await userRepostiory.getMyPageInfo()
    }
    
    public func putMyInfo(_ reqDTO: PutMyInfoReqDTO, profileImage: Data?) async throws -> EmptyResponse {
        return try await userRepostiory.putMyInfo(reqDTO, profileImage: profileImage)
    }
}
