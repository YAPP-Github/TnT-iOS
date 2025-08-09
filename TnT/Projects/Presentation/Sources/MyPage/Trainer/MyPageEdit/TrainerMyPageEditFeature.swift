//
//  TrainerMyPageEditFeature.swift
//  Presentation
//
//  Created by 박민서 on 7/6/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import UIKit
import _PhotosUI_SwiftUI
import ComposableArchitecture

import Domain
import DesignSystem

@Reducer
/// 트레이너 마이페이지 내 정보 수정을 담당하는 리듀서입니다.
public struct TrainerMyPageEditFeature {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        // MARK: Data related state
        /// 현재 유저 정보
        var currentUserInfo: EditUserInfoEntity
        /// 현재 입력된 사용자 이름
        var userName: String
        /// 선택된 프로필 이미지
        var userImageData: Data?
        // MARK: UI related state
        /// 텍스트 필드 상태 (빈 값 / 입력됨 / 유효하지 않음)
        var view_textFieldStatus: TTextField.Status
        /// 포토 피커 표시 여부
        var view_isPhotoPickerPresented: Bool
        /// "다음" 버튼 활성화 여부
        var view_isDoneButtonEnabled: Bool
        /// 현재 선택된 이미지 (PhotosPickerItem)
        var view_photoPickerItem: PhotosPickerItem?
        /// 하단 푸터 텍스트 표시 여부 (이름이 유효하지 않을 경우 표시)
        var view_isFooterTextVisible: Bool {
            return view_textFieldStatus == .invalid
        }
        /// 표시되는 팝업
        var view_popUp: PopUp?
        /// 팝업 표시 여부
        var view_isPopUpPresented: Bool
        
        // MARK: SubFeature state
        var photoLibraryState = PhotoLibraryFeature.State()
        
        public init(
            currentUserInfo: EditUserInfoEntity,
            view_textFieldStatus: TTextField.Status = .empty,
            view_isPhotoPickerPresented: Bool = false,
            view_isNextButtonEnabled: Bool = false,
            view_photoPickerItem: PhotosPickerItem? = nil,
            view_popUp: PopUp? = nil,
            view_isPopUpPresented: Bool = false
        ) {
            self.currentUserInfo = currentUserInfo
            self.userName = currentUserInfo.name
            self.userImageData = currentUserInfo.profileImage
            self.view_textFieldStatus = view_textFieldStatus
            self.view_isPhotoPickerPresented = view_isPhotoPickerPresented
            self.view_isDoneButtonEnabled = view_isNextButtonEnabled
            self.view_photoPickerItem = view_photoPickerItem
            self.view_popUp = view_popUp
            self.view_isPopUpPresented = view_isPopUpPresented
        }
    }
    
    @Dependency(\.userUseCase) private var userUseCase: UserUseCase
    @Dependency(\.userUseRepoCase) private var userUseRepoCase: UserRepository
    @Dependency(\.dismiss) private var dismiss
    
    public enum Action: Sendable, ViewAction {
        /// 뷰에서 발생한 액션을 처리합니다.
        case view(View)
        /// api 콜 액션을 처리합니다
        case api(APIAction)
        /// 하위 피처 액션을 처리합니다
        case subFeature(SubFeatureAction)
        /// 선택된 이미지 데이터 저장
        case imagePicked(Data?)
        /// 네비게이션 여부 설정
        case setNavigating
        
        @CasePathable
        public enum View: Sendable, BindableAction {
            /// 바인딩할 액션을 처리합니다
            case binding(BindingAction<State>)
            /// 네비게이션 백 버튼 탭
            case tapNavBackButton
            /// 프로필 사진 변경 버튼이 눌렸을 때 (사진 선택 모달 띄우기)
            case tapWriteButton
            /// "완료" 버튼이 눌렸을 때
            case tapDoneButton
            /// 팝업 좌측 secondary 버튼 탭
            case tapPopUpSecondaryButton(popUp: PopUp)
            /// 팝업 우측 primary 버튼 탭
            case tapPopUpPrimaryButton(popUp: PopUp)
        }
        
        @CasePathable
        public enum APIAction: Sendable {

            /// 회원가입 POST
            case postSignUp(fcmToken: String)
        }
        
        @CasePathable
        public enum SubFeatureAction: Sendable {
            case photoLibrary(PhotoLibraryFeature.Action)
        }
    }
    
    public var body: some ReducerOf<Self> {
        
        Scope(state: \.photoLibraryState, action: \.subFeature.photoLibrary) {
            PhotoLibraryFeature()
        }
        
        BindingReducer(action: \.view)
        
        Reduce { state, action in
            switch action {
            case .view(let action):
                switch action {
                case .binding(\.userName):
                    return self.validate(&state)
                    
                case .binding(\.view_photoPickerItem):
                    let item: PhotosPickerItem? = state.view_photoPickerItem
                    return .run { [item] send in
                        if let item, let data = try? await item.loadTransferable(type: Data.self) {
                            await send(.imagePicked(data))
                        }
                    }
                    
                case .binding:
                    return .none
                    
                case .tapNavBackButton:
                    if state.view_isDoneButtonEnabled {
                        return self.setPopUpStatus(&state, status: .cancelEditing)
                    } else {
                        return .run { send in
                            await self.dismiss()
                        }
                    }
                    
                case .tapWriteButton:
                    state.view_isPhotoPickerPresented = true
                    return .none
                    
                case .tapDoneButton:
                    return .send(.api(.postSignUp(fcmToken: "")))
                    
                case .tapPopUpSecondaryButton(let popUp):
                    switch popUp {
                    case .photoAuthorization:
                        return setPopUpStatus(&state, status: nil)
                        
                    case .cancelEditing:
                        return .concatenate(
                            setPopUpStatus(&state, status: nil),
                            .send(.setNavigating)
                        )
                    }
                    
                case .tapPopUpPrimaryButton(let popUp):
                    switch popUp {
                    case .photoAuthorization:
                        if let url = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    
                        return .none
                        
                    case .cancelEditing:
                        return .concatenate(
                            setPopUpStatus(&state, status: nil),
                            .send(.setNavigating)
                        )
                    }
                }
                
            case .api(let action):
                switch action {
                    
                case .postSignUp:
                    // 추후 API 로직 작성
                    return .none
                }
                
            case .subFeature(let internalAction):
                switch internalAction {
                case .photoLibrary(.showPermissionPopup):
                    return setPopUpStatus(&state, status: .photoAuthorization)
                    
                default:
                    return .none
                }
            case .imagePicked(let imgData):
                state.userImageData = imgData
                return .none
                
            case .setNavigating:
                return .none
            }
        }
    }
}

// MARK: Internal Logic
private extension TrainerMyPageEditFeature {
    /// 사용자 입력값을 검증하고 상태를 업데이트합니다.
    func validate(_ state: inout State) -> Effect<Action> {
        guard !state.userName.isEmpty, userUseCase.validateUserName(state.userName) else {
            state.view_textFieldStatus = state.userName.isEmpty ? .empty : .invalid
            state.view_isDoneButtonEnabled = false
            return .none
        }
        
        state.view_textFieldStatus = .filled
        state.view_isDoneButtonEnabled = true
        return .none
    }
    
    /// 팝업 상태, 표시 상태를 업데이트
    /// status nil 입력인 경우 팝업 표시 해제
    func setPopUpStatus(_ state: inout State, status: PopUp?) -> Effect<Action> {
        state.view_popUp = status
        state.view_isPopUpPresented = status != nil
        return .none
    }
}

// MARK: PopUp
public extension TrainerMyPageEditFeature {
    /// 본 화면에 팝업으로 표시되는 목록
    enum PopUp: Equatable, Sendable {
        /// 사진 접근 권한이 필요해요
        case photoAuthorization
        /// 정보 수정을 종료할까요?
        case cancelEditing
        
        var title: String {
            switch self {
            case .photoAuthorization:
                return "프로필 사진 설정을 위해\n사진 접근 권한이 필요해요"
                
            case .cancelEditing:
                return "정보 수정을 종료할까요?"
            }
        }
        
        var message: String {
            switch self {
            case .photoAuthorization:
                return "‘TnT'는 프로필 사진 설정, 운동 기록 및 식단 기록 저장 등 주요 기능 제공을 위해 사진 접근 권한이 필요합니다.\n설정에서 권한을 활성화해주세요."
            case .cancelEditing:
                return "수정 사항이 저장되지 않아요!"
            }
        }
        
        var showAlertIcon: Bool {
            switch self {
            case .photoAuthorization:
                return false
            case .cancelEditing:
                return true
            }
        }
        
        var secondaryTitle: String {
            switch self {
            case .photoAuthorization:
                return "취소"
            case .cancelEditing:
                return "종료"
            }
        }
        
        var secondaryAction: Action.View {
            return .tapPopUpSecondaryButton(popUp: self)
        }
        
        var primaryTitle: String {
            switch self {
            case .photoAuthorization:
                return "확인"
            case .cancelEditing:
                return "계속 수정"
            }
        }
        
        var primaryAction: Action.View {
            return .tapPopUpPrimaryButton(popUp: self)
        }
    }
}

import Foundation
/// 회원 정보 수정 요청 Entity
public struct EditUserInfoEntity: Equatable {
    
    public init(
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
