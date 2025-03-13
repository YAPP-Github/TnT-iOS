//
//  NetworkError.swift
//  Data
//
//  Created by 박민서 on 1/21/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation

/// 네트워크 오류 정의
enum NetworkError: Error {
    
    // MARK: - Client Errors (400 ~ 499)
    case clientError(statusCode: Int, message: String?)
    case badRequest(message: String?)     // 400
    case unauthorized(message: String?)   // 401
    case forbidden(message: String?)      // 403
    case notFound(message: String?)       // 404
    case conflict(message: String?)       // 409

    // MARK: - Server Errors (500 ~ 599)
    case serverError(statusCode: Int, message: String?)

    // MARK: - Connection Errors
    case timeout                // 요청 시간 초과
    case noInternet             // 네트워크 연결 없음

    // MARK: - Parsing Errors
    case decodingError(message: String?)  // 디코딩 실패

    // MARK: - Unknown Errors
    case unknown(statusCode: Int?, message: String?)
}

// MARK: - Error Description
extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .clientError(let statusCode, let message),
             .serverError(let statusCode, let message):
            return "[\(statusCode)] \(message ?? "오류 발생")"
        case .badRequest(let message):
            return "[400] \(message ?? "잘못된 요청입니다.")"
        case .unauthorized(let message):
            return "[401] \(message ?? "인증이 필요합니다.")"
        case .forbidden(let message):
            return "[403] \(message ?? "권한이 없습니다.")"
        case .notFound(let message):
            return "[404] \(message ?? "요청한 리소스를 찾을 수 없습니다.")"
        case .conflict(let message):
            return "[409] \(message ?? "요청이 충돌되었습니다.")"
        case .timeout:
            return "요청 시간이 초과되었습니다."
        case .noInternet:
            return "네트워크 연결이 없습니다."
        case .decodingError(let message):
            return "디코딩 실패: \(message ?? "JSON 변환 오류")"
        case .unknown(let statusCode, let message):
            return "[\(statusCode ?? 0)] \(message ?? "알 수 없는 오류 발생")"
        }
    }
    
    /// UI 표시 여부
    var isUIToastError: Bool {
        switch self {
        case .notFound, .conflict:
            return true
        default:
            return false
        }
    }
}
