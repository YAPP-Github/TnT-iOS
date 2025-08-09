//
//  UserMapper.swift
//  Domain
//
//  Created by 박민서 on 2/12/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation

public extension GetMyPageInfoResDTO {
    func toEntity() -> TraineeMyPageEntity {
        return .init(
            isConnected: self.trainee?.isConnected ?? false,
            name: self.name,
            profileImageUrl: self.profileImageUrl,
            socialType: self.socialType
        )
    }
    
    func toEntity() -> TrainerMyPageEntity {
        return .init(
            name: self.name,
            profileImageUrl: self.profileImageUrl,
            socialType: self.socialType,
            activeTraineeCount: self.trainer?.activeTraineeCount,
            totalTraineeCount: self.trainer?.totalTraineeCount
        )
    }
}

public extension EditUserInfoEntity {
    func toDTO() -> PutMyInfoReqDTO {
        return .init(
            removeImage: self.removeImage,
            memberType: self.memberType.englishName,
            name: self.name,
            birthday: self.birthday?.toString(format: .yyyyMMdd),
            height: self.height,
            weight: self.weight,
            cautionNote: self.cautionNote,
            goalContents: self.goalContents
        )
    }
}
