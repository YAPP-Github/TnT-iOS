//
//  EmptyResponse.swift
//  Data
//
//  Created by 박민서 on 2/9/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation

/// 비어 있는 응답을 처리할 빈 구조체
public struct EmptyResponse: Decodable {
    public init() {}
}

public struct ErrorResponse: Decodable {
    public let message: String
}
