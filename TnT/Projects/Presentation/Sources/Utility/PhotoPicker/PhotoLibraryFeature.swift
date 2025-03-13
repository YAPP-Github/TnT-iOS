//
//  PhotoLibraryFeature.swift
//  Presentation
//
//  Created by 박민서 on 2/17/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Photos
import UIKit
import ComposableArchitecture

@Reducer
public struct PhotoLibraryFeature {
    @ObservableState
    public struct State: Equatable {
        /// 접근 권한 허용 여부
        var isAuthorized: Bool = false
    }
    
    public enum Action: Equatable, Sendable {
        /// 권한 체크
        case checkPermission
        /// 권한 요청
        case requestPermission
        /// 권한 상태 반영
        case setAuthorizedStatus(Bool)
        /// 권한 관련 팝업 표시
        case showPermissionPopup
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .checkPermission:
                let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                let authorized = (status == .authorized || status == .limited)
                return .send(.setAuthorizedStatus(authorized))
                
            case .requestPermission:
                return .run { send in
                    let status = await requestPhotoAuthorization()
                    let authorized = (status == .authorized || status == .limited)
                    if authorized {
                        await send(.setAuthorizedStatus(authorized))
                    } else {
                        await send(.showPermissionPopup)
                    }
                }
                
            case let .setAuthorizedStatus(authorized):
                state.isAuthorized = authorized
                return .none
                
            case .showPermissionPopup:
                return .none
            }
        }
    }
}

extension PhotoLibraryFeature {
    /// 권한 요청 진행
    func requestPhotoAuthorization() async -> PHAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                continuation.resume(returning: newStatus)
            }
        }
    }
}
