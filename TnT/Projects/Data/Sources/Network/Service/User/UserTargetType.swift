//
//  UserTargetType.swift
//  Data
//
//  Created by 박민서 on 1/25/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation

import Domain

/// 사용자 관련 API 요청 타입 정의
public enum UserTargetType {
    /// 로그인 세션 유효 확인
    case getSessionCheck
    /// 소셜 로그인 요청
    case postSocialLogin(reqDTO: PostSocialLoginReqDTO)
    /// 회원가입 요청
    case postSignUp(reqDTO: PostSignUpReqDTO, imgData: Data?)
    /// 로그아웃 요청
    case postLogout
    /// 회원 탈퇴 요청
    case postWithdrawal
    /// 마이페이지 정보 요청
    case getMyPageInfo
    /// 회원 정보 수정 요청
    case putUpdateUserInfo(reqDTO: UpdateUserInfoRequestDTO, imgData: Data?)
}

extension UserTargetType: TargetType {
    var baseURL: URL {
        return URL(string: Config.apiBaseUrlDev)!
    }
    
    var path: String {
        switch self {
        case .getSessionCheck:
            return "/check-session"

        case .postSocialLogin:
            return "/login"

        case .postSignUp:
            return "/members/sign-up"

        case .postLogout:
            return "/logout"

        case .postWithdrawal:
            return "/members/withdraw"

        case .getMyPageInfo, .putUpdateUserInfo:
            return "/members"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getSessionCheck, .getMyPageInfo:
            return .get

        case .postSocialLogin, .postSignUp, .postLogout, .postWithdrawal:
            return .post

        case .putUpdateUserInfo:
            return .put
        }
    }
    
    var task: RequestTask {
        switch self {
        case .getSessionCheck, .postLogout, .postWithdrawal, .getMyPageInfo:
            return .requestPlain

        case .postSocialLogin(let reqDto):
            return .requestJSONEncodable(encodable: reqDto)

        case let .postSignUp(reqDto, imgData):
            let jsons: [MultipartJSON] = [.init(jsonName: "request", json: reqDto)]

            // 프로필 이미지가 있을 경우 멀티파트 업로드 처리
            let files: [MultipartFile] = imgData.map {
                [.init(fieldName: "profileImage", fileName: "profile.png", mimeType: "image/png", data: $0)]
            } ?? []

            return .uploadMultipart(jsons: jsons, files: files, additionalFields: [:])

        case let .putUpdateUserInfo(reqDto, imgData):
            let jsons: [MultipartJSON] = [.init(jsonName: "request", json: reqDto)]

            // 프로필 이미지가 있을 경우 멀티파트 업로드 처리
            let files: [MultipartFile] = imgData.map {
                [.init(fieldName: "profileImage", fileName: "profile.png", mimeType: "image/png", data: $0)]
            } ?? []

            return .uploadMultipart(jsons: jsons, files: files, additionalFields: [:])
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .getSessionCheck, .postLogout, .postWithdrawal, .getMyPageInfo:
            return nil

        case .postSocialLogin:
            return ["Content-Type": "application/json"]

        case .postSignUp, .putUpdateUserInfo:
            return ["Content-Type": "multipart/form-data"]
        }
    }
    
    var interceptors: [any Interceptor] {
        switch self {
        case .getSessionCheck, .postLogout, .postWithdrawal, .getMyPageInfo, .putUpdateUserInfo:
            return [
                LoggingInterceptor(),
                AuthTokenInterceptor(),
                ProgressIndicatorInterceptor(),
                ResponseValidatorInterceptor(),
                RetryInterceptor(maxRetryCount: 2)
            ]
        default:
            return [
                LoggingInterceptor(),
                ResponseValidatorInterceptor(),
                ProgressIndicatorInterceptor(),
                RetryInterceptor(maxRetryCount: 2)
            ]
        }
    }
}
