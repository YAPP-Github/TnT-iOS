//
//  NetworkService.swift
//  Data
//
//  Created by 박민서 on 1/21/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation

import Domain

/// 네트워크 요청을 처리하는 서비스 클래스
public final class NetworkService {
    
    public static let shared: NetworkService = NetworkService()
    
    private let session: URLSession
    
    /// 초기화 메서드 내부 제한
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// 일반적인 네트워크 요청 처리 메서드
    /// - Parameters:
    ///   - target: TargetType으로 정의된 요청 정보
    ///   - decodingType: 디코딩할 타입
    /// - Returns: 디코딩된 결과를 포함한 Result 타입
    func request<T: Decodable>(
        _ target: TargetType,
        decodingType: T.Type
    ) async throws -> T {
        let pipeline: InterceptorPipeline = InterceptorPipeline(interceptors: target.interceptors)
        do {
            // URL Request 생성
            var request: URLRequest = try buildRequest(from: target)
            request = try await pipeline.adapt(request)
            
            // Request 수행
            let data: Data = try await executeRequest(request, pipeline: pipeline)
            
            // Data 디코딩
            return try decodeData(data, as: decodingType)
        } catch let error as NetworkError {
            // TODO: 추후 인터셉터 리팩토링 시 error middleWare로 분리
            NotificationCenter.default.postProgress(visible: false)
            switch error {
            case .unauthorized:
                NotificationCenter.default.postSessionExpired()
            case .notFound(let message), .conflict(let message):
                NotificationCenter.default.post(toast: .init(presentType: .text("⚠"), message: message ?? ""))
            default:
                NotificationCenter.default.post(toast: .init(presentType: .text("⚠"), message: "서버 요청에 실패했어요"))
            }
            throw error
        }
    }
}

// MARK: - Private Helper Methods
private extension NetworkService {
    /// URLRequest 생성
    func buildRequest(from target: TargetType) throws -> URLRequest {
        let url: URL = target.baseURL.appendingPathComponent(target.path)
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        target.headers?.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        return try target.task.configureURLRequest(request)
    }
    
    /// 요청 실행 및 재시도 처리
    func executeRequest(_ request: URLRequest, pipeline: InterceptorPipeline) async throws -> Data {
        let maxRetryCount: Int = pipeline.getMaxRetryCount() ?? 0
        return try await performRequestWithRetry(with: maxRetryCount) { attempt in
            let (data, response): (Data, URLResponse) = try await session.data(for: request)
            try await pipeline.validate(response, data: data)
            return data
        }
    }
    
    /// 재시도 로직 처리
    func performRequestWithRetry<T>(with maxRetryCount: Int, _ operation: (_ attempt: Int) async throws -> T) async throws -> T {
        var attempt: Int = 0
        while attempt <= maxRetryCount {
            do {
                return try await operation(attempt)
            } catch let error as NetworkError {
                attempt += 1
                if attempt >= maxRetryCount {
                    throw error
                }
                // 재시도 시 지연 시간 추가
                try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt)) * 100_000_000))
            }
        }
        throw NetworkError.unknown(statusCode: nil, message: "Max retry limit reached")
    }
    
    /// JSON 데이터 디코딩
    func decodeData<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        // 빈 데이터인 경우 EmptyResponse 타입으로 처리
        if data.isEmpty, let emptyValue = EmptyResponse() as? T { return emptyValue }
        
        do {
            return try JSONDecoder(setting: .defaultSetting).decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingError(message: decodingError.localizedDescription)
        }
    }
}
