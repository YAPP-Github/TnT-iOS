//
//  UserType.swift
//  Domain
//
//  Created by 박민서 on 1/17/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation

/// 앱에서 존재하는 사용자 유형을 정의한 열거형
public enum UserType: Sendable {
    case trainer
    case trainee
}

public extension UserType {
    /// 유저 타입을 한글로 변환하여 반환
    var koreanName: String {
        switch self {
        case .trainer:
            return "트레이너"
        case .trainee:
            return "트레이니"
        }
    }
    
    var englishName: String {
        switch self {
        case .trainer:
            return "TRAINER"
        case .trainee:
            return "TRAINEE"
        }
    }
}
