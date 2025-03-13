//
//  ResponseValidator.swift
//  Data
//
//  Created by 박민서 on 1/21/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation

import Domain

struct ResponseValidatorInterceptor: Interceptor {
    let priority: InterceptorPriority = .normal

    func validate(response: URLResponse, data: Data) async throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(statusCode: nil, message: "Invalid response")
        }

        let statusCode: Int = httpResponse.statusCode
        switch statusCode {
        case 200..<300:
            return
        default:
            try throwError(with: data, statusCode: statusCode)
        }
    }
    
    private func throwError(with data: Data, statusCode: Int) throws {
        let responseBody: String = try JSONDecoder().decode(ErrorResponse.self, from: data).message
        
        switch statusCode {
        case 400:
            throw NetworkError.badRequest(message: responseBody)
            
        case 401:
            throw NetworkError.unauthorized(message: responseBody)
            
        case 403:
            throw NetworkError.forbidden(message: responseBody)
            
        case 404:
            throw NetworkError.notFound(message: responseBody)
        
        case 409:
            throw NetworkError.conflict(message: responseBody)
            
        case 405..<500:
            throw NetworkError.clientError(statusCode: statusCode, message: responseBody)
            
        case 500..<600:
            throw NetworkError.serverError(statusCode: statusCode, message: responseBody)
            
        default:
            throw NetworkError.unknown(statusCode: statusCode, message: responseBody)
        }
    }
}
