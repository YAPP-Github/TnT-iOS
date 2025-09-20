//
//  EditUserInfoEntity.swift
//  Domain
//
//  Created by 박민서 on 8/9/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation

/// 회원 정보 수정 요청 Entity
public struct EditUserInfoEntity: Equatable {
    
    public init(
        prevProfileImageURL: String? = nil,
        profileImage: Data? = nil,
        removeImage: Bool,
        memberType: UserType,
        name: String,
        birthday: Date? = nil,
        height: Double? = nil,
        weight: Double? = nil,
        cautionNote: String? = nil,
        goalContents: [String]? = nil
    ) {
        self.prevProfileImageURL = prevProfileImageURL
        self.profileImage = profileImage
        self.removeImage = removeImage
        self.memberType = memberType
        self.name = name
        self.birthday = birthday
        self.height = height
        self.weight = weight
        self.cautionNote = cautionNote
        self.goalContents = goalContents
    }
    public var prevProfileImageURL: String?
    public var profileImage: Data?
    public var removeImage: Bool
    public var memberType: UserType
    public var name: String
    public var birthday: Date?
    public var height: Double?
    public var weight: Double?
    public var cautionNote: String?
    public var goalContents: [String]?
}
