//
//  TrainingPurpose.swift
//  Domain
//
//  Created by 박민서 on 1/24/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation

/// 사용자의 운동 목적을 정의하는 열거형
public enum TrainingPurpose: Sendable, CaseIterable {
    /// 체중 감량
    case loseWeight
    /// 근력 향상
    case gainMuscle
    /// 건강 관리
    case healthWellness
    /// 유연성 향상
    case flexibilityImprovement
    /// 바디프로필 준비
    case bodyProfile
    /// 자세 교정
    case postureCorrection
}

public extension TrainingPurpose {
    /// 운동 목적을 한글로 변환하여 반환
    var koreanName: String {
        switch self {
        case .loseWeight:
            return "체중 감량"
        case .gainMuscle:
            return "근력 향상"
        case .healthWellness:
            return "건강 관리"
        case .flexibilityImprovement:
            return "유연성 향상"
        case .bodyProfile:
            return "바디프로필"
        case .postureCorrection:
            return "자세 교정"
        }
    }

    /// 한글 이름으로부터 TrainingPurpose를 생성
    init?(koreanName: String) {
        switch koreanName {
        case "체중 감량":
            self = .loseWeight
        case "근력 향상":
            self = .gainMuscle
        case "건강 관리":
            self = .healthWellness
        case "유연성 향상":
            self = .flexibilityImprovement
        case "바디프로필":
            self = .bodyProfile
        case "자세 교정":
            self = .postureCorrection
        default:
            return nil
        }
    }
}
