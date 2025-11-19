//
//  MyPageEntity.swift
//  Domain
//
//  Created by 박민서 on 2/12/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation

public struct TraineeMyPageEntity: Equatable, Sendable, Codable {
    /// 트레이니 연결 여부
    public let isConnected: Bool
    /// 트레이니 이름
    public let name: String
    /// 트레이니 프로필 이미지 URL
    public let profileImageUrl: String
    /// 소셜 타입
    public let socialType: String
    
    /// 생년월일
    public let birthday: String?
    /// 나이
    public let age: Int?
    /// 키 (cm)
    public let height: Double?
    /// 몸무게 (kg)
    public let weight: Double?
    /// 주의사항
    public let cautionNote: String?
    /// PT 목표
    public let ptGoals: [String]
    
    public init(
        isConnected: Bool,
        name: String,
        profileImageUrl: String,
        socialType: String,
        birthday: String?,
        age: Int?,
        height: Double?,
        weight: Double?,
        cautionNote: String?,
        ptGoals: [String]
    ) {
        self.isConnected = isConnected
        self.name = name
        self.profileImageUrl = profileImageUrl
        self.socialType = socialType
        self.birthday = birthday
        self.age = age
        self.height = height
        self.weight = weight
        self.cautionNote = cautionNote
        self.ptGoals = ptGoals
    }
    
    public init() {
        self.isConnected = false
        self.name = ""
        self.profileImageUrl = ""
        self.socialType = ""
        self.birthday = ""
        self.age = 0
        self.height = 0
        self.weight = 0
        self.cautionNote = ""
        self.ptGoals = []
    }
}

public struct TrainerMyPageEntity: Equatable, Sendable {
    /// 트레이너 이름
    public let name: String
    /// 트레이너 프로필 이미지 URL
    public let profileImageUrl: String
    /// 소셜 타입
    public let socialType: String
    /// 관리 중인 회원 수
    public let activeTraineeCount: Int?
    /// 함께했던 회원 수
    public let totalTraineeCount: Int?
}
