//
//  Image+DesignSystem.swift
//  DesignSystem
//
//  Created by 박민서 on 1/12/25.
//  Copyright © 2025 yapp25-app2team. All rights reserved.
//

import SwiftUI

extension DesignSystemImages {
    var imageResource: ImageResource {
        ImageResource(name: self.name, bundle: .module)
    }
}

// MARK: Icon
public extension ImageResource {
    static let icnArrowDown: ImageResource = DesignSystemAsset.icnArrowDown.imageResource
    static let icnArrowLeft: ImageResource = DesignSystemAsset.icnArrowLeft.imageResource
    static let icnDelete: ImageResource = DesignSystemAsset.icnDelete.imageResource
    static let icnFeedbackEmpty: ImageResource = DesignSystemAsset.icnFeedbackEmpty.imageResource
    static let icnFeedbackFilled: ImageResource = DesignSystemAsset.icnFeedbackFilled.imageResource
    static let icnHomeEmpty: ImageResource = DesignSystemAsset.icnHomeEmpty.imageResource
    static let icnHomeFilled: ImageResource = DesignSystemAsset.icnHomeFilled.imageResource
    static let icnListEmpty: ImageResource = DesignSystemAsset.icnListEmpty.imageResource
    static let icnListFilled: ImageResource = DesignSystemAsset.icnListFilled.imageResource
    static let icnMypageEmpty: ImageResource = DesignSystemAsset.icnMypageEmpty.imageResource
    static let icnMypageFilled: ImageResource = DesignSystemAsset.icnMypageFilled.imageResource
    static let icnWriteWhite: ImageResource = DesignSystemAsset.icnWriteWhite.imageResource
    static let icnWriteBlack: ImageResource = DesignSystemAsset.icnWriteBlack.imageResource
    static let icnWriteGray: ImageResource = DesignSystemAsset.icnWriteGray.imageResource
    static let icnRadioButtonUnselected: ImageResource = DesignSystemAsset.icnRadioButtonUnselected.imageResource
    static let icnRadioButtonSelected: ImageResource = DesignSystemAsset.icnRadioButtonSelected.imageResource
    static let icnCheckMarkEmpty: ImageResource = DesignSystemAsset.icnCheckMarkEmpty.imageResource
    static let icnCheckMarkGreen: ImageResource = DesignSystemAsset.icnCheckMarkGreen.imageResource
    static let icnCheckMarkFilled: ImageResource = DesignSystemAsset.icnCheckMarkFilled.imageResource
    static let icnCheckMarkLightGreen: ImageResource = DesignSystemAsset.icnCheckMarkLightGreen.imageResource
    static let icnCheckButtonUnselected: ImageResource = DesignSystemAsset.icnCheckButtonUnselected.imageResource
    static let icnCheckButtonSelected: ImageResource = DesignSystemAsset.icnCheckButtonSelected.imageResource
    static let icnStarEmpty: ImageResource = DesignSystemAsset.icnStarEmpty.imageResource
    static let icnStarFilled: ImageResource = DesignSystemAsset.icnStarFilled.imageResource
    static let icnHeartEmpty: ImageResource = DesignSystemAsset.icnHeartEmpty.imageResource
    static let icnHeartFilled: ImageResource = DesignSystemAsset.icnHeartFilled.imageResource
    static let icnKakao: ImageResource = DesignSystemAsset.icnKakao.imageResource
    static let icnApple: ImageResource = DesignSystemAsset.icnApple.imageResource
    static let icnTriangleDown: ImageResource = DesignSystemAsset.icnTriangleDown.imageResource
    static let icnTriangleRight: ImageResource = DesignSystemAsset.icnTriangleRight.imageResource
    static let icnClock: ImageResource = DesignSystemAsset.icnClock.imageResource
    static let icnClockRed: ImageResource = DesignSystemAsset.icnClockRed.imageResource
    static let icnStar: ImageResource = DesignSystemAsset.icnStar.imageResource
    static let icnStarSmile: ImageResource = DesignSystemAsset.icnStarSmile.imageResource
    static let icnWriteBlackFilled: ImageResource = DesignSystemAsset.icnWriteBlackFilled.imageResource
    static let icnPlus: ImageResource = DesignSystemAsset.icnPlus.imageResource
    static let icnPlusEmpty: ImageResource = DesignSystemAsset.icnPlusEmpty.imageResource
    static let icnPlusGray: ImageResource = DesignSystemAsset.icnPlusGray.imageResource
    static let icnAlarm: ImageResource = DesignSystemAsset.icnAlarm.imageResource
    static let icnCalendar: ImageResource = DesignSystemAsset.icnCalendar.imageResource
    static let icnDelete24px: ImageResource = DesignSystemAsset.icnDelete24.imageResource
    static let icnSearch: ImageResource = DesignSystemAsset.icnSearch.imageResource
    static let icnAddition: ImageResource = DesignSystemAsset.icnAddition.imageResource
    static let icnImage: ImageResource = DesignSystemAsset.icnImage.imageResource
    static let icnSubtraction: ImageResource = DesignSystemAsset.icnSubstraction.imageResource
    static let icnBomb: ImageResource = DesignSystemAsset.icnBomb.imageResource
    static let icnBombEmpty: ImageResource = DesignSystemAsset.icnBombEmpty.imageResource
    static let icnSchedule: ImageResource = DesignSystemAsset.icnSchedule.imageResource
    static let icnCheckBoxSelected: ImageResource = DesignSystemAsset.icnCheckBoxSelected.imageResource
    static let icnCheckBoxUnselected: ImageResource = DesignSystemAsset.icnCheckBoxUnselected.imageResource
    static let icnEllipsis: ImageResource = DesignSystemAsset.icnElipses.imageResource
    static let icnArrowRight: ImageResource = DesignSystemAsset.icnArrowRight.imageResource
    static let icnArrowUp: ImageResource = DesignSystemAsset.icnArrowUp.imageResource
    static let icnTriangleLeft32px: ImageResource = DesignSystemAsset.icnTriangleLeft32.imageResource
    static let icnTriangleRight32px: ImageResource = DesignSystemAsset.icnTriangleRight32.imageResource
    static let icnWarning: ImageResource = DesignSystemAsset.icnWarning.imageResource
    static let icnQuestionMark: ImageResource = DesignSystemAsset.icnQuestionMark.imageResource
}

// MARK: Image
public extension ImageResource {
    static let imgAppSplash: ImageResource = DesignSystemAsset.imgAppSplash.imageResource
    static let imgDefaultTraineeImage: ImageResource = DesignSystemAsset.imgDefaultTraineeImage.imageResource
    static let imgDefaultTrainerImage: ImageResource = DesignSystemAsset.imgDefaultTrainerImage.imageResource
    static let imgOnboardingLogin: ImageResource = DesignSystemAsset.imgOnboardingLogin.imageResource
    static let imgOnboardingTrainee: ImageResource = DesignSystemAsset.imgOnboardingTrainee.imageResource
    static let imgOnboardingTrainer: ImageResource = DesignSystemAsset.imgOnboardingTrainer.imageResource
    static let imgBoom: ImageResource = DesignSystemAsset.imgBoom.imageResource
    static let imgConnectionCompleteBackground: ImageResource = DesignSystemAsset.imgConnectioncompletebackground.imageResource
}
