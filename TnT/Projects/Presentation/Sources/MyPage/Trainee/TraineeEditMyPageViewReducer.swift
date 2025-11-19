//
//  TraineeEditMyPageViewReducer.swift
//  Presentation
//
//  Created by 박서연 on 11/20/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import UIKit
import Photos
import _PhotosUI_SwiftUI
import UserNotifications

import ComposableArchitecture

import Domain
import DesignSystem

@Reducer
public struct TraineeEditMyPageViewReducer {
    @ObservableState

    public struct State: Equatable {
        // MARK: - Shared Data
        @Shared(.trainee) var traineeData = .init()

        // MARK: - Image Data
        /// 현재 선택된 프로필 이미지 (데이터 형식)
        var userImageData: Data?
        /// 기존 프로필 이미지 URL (서버에서 가져온)
        var existingImageUrl: String?
        /// 현재 선택된 이미지 (PhotosPickerItem)
        var view_photoPickerItem: PhotosPickerItem?

        // MARK: - Edit Data
        /// 이름
        var userName: String = ""
        /// 생년월일
        var birthDate: String = ""
        /// 키
        var height: String = ""
        /// 몸무게
        var weight: String = ""
        /// 주의사항
        var cautionNote: String = ""
        /// PT 목적
        var selectedPurposes: [TrainingPurpose] = []

        // MARK: - UI State
        /// 표시되는 팝업
        var view_popUp: PopUp?
        /// 팝업 표시 여부
        var view_isPopUpPresented: Bool
        /// 바텀시트 표시 여부
        var view_isPhotoMenuBottomSheetPresented: Bool = false
        /// 생년월일 DatePicker 표시 여부
        var view_isDatePickerPresented: Bool = false
        /// 생년월일 필드 상태
        var view_birthDateStatus: TTextField.Status = .empty
        /// 키 필드 상태
        var view_heightStatus: TTextField.Status = .empty
        /// 몸무게 필드 상태
        var view_weightStatus: TTextField.Status = .empty
        /// 주의사항 에디터 상태
        var view_editorStatus: TTextEditor.Status = .empty
        /// 주의사항 최대 글자 수
        var view_editorMaxCount: Int? = 100

        // MARK: - Original Data (for change detection)
        /// 초기 프로필 이미지 URL
        var originalImageUrl: String?
        /// 초기 프로필 이미지 데이터
        var originalImageData: Data?
        /// 초기 생년월일
        var originalBirthDate: String = ""
        /// 초기 키
        var originalHeight: String = ""
        /// 초기 몸무게
        var originalWeight: String = ""
        /// 초기 주의사항
        var originalCautionNote: String = ""
        /// 초기 PT 목적
        var originalPurposes: [TrainingPurpose] = []

        // MARK: - SubFeature
        var photoLibraryState = PhotoLibraryFeature.State()

        /// 이미지 표시 우선순위: 새로 선택한 이미지 > 기존 URL 이미지 > 기본 이미지
        var displayImageData: Data? {
            return userImageData
        }

        /// 변경사항이 있는지 확인
        var hasChanges: Bool {
            // 이미지 변경 확인
            // 1. 새로운 이미지가 선택된 경우 (userImageData와 originalImageData가 다름)
            // 2. 이미지가 삭제된 경우 (원래 있었는데 nil이 됨)
            let imageChanged = userImageData != originalImageData

            // 각 필드 변경 확인
            let birthDateChanged = birthDate != originalBirthDate
            let heightChanged = height != originalHeight
            let weightChanged = weight != originalWeight
            let cautionNoteChanged = cautionNote != originalCautionNote
            let purposesChanged = Set(selectedPurposes) != Set(originalPurposes)

            return imageChanged || birthDateChanged || heightChanged ||
                   weightChanged || cautionNoteChanged || purposesChanged
        }

        public init(
            userImageData: Data? = nil,
            view_popUp: PopUp? = nil,
            view_isPopUpPresented: Bool = false
        ) {
            self.userImageData = userImageData
            self.existingImageUrl = nil
            self.view_popUp = view_popUp
            self.view_isPopUpPresented = view_isPopUpPresented
        }
    }

    public enum Action: Sendable, ViewAction {
        /// 뷰에서 발생한 액션을 처리합니다.
        case view(View)
        /// API 콜 액션 처리
        case api(APIAction)
        /// 하위 피처 액션을 처리합니다
        case subFeature(SubFeatureAction)
        /// 팝업 세팅 처리 (내부 액션)
        case setPopUpStatus(PopUp?)
        /// 선택된 이미지 데이터 저장
        case imagePicked(Data?)
        /// 화면 진입 시 기존 이미지 로드
        case loadExistingImage
        /// 기존 이미지 로드 완료 (원본 저장용)
        case existingImageLoaded(Data)

        @CasePathable
        public enum View: Sendable, BindableAction {
            /// 바인딩할 액션을 처리
            case binding(BindingAction<State>)
            /// 화면 진입 시
            case onAppear
            /// 프로필 이미지 연필 아이콘 탭 (바텀시트 표시)
            case tapProfileImageEditButton
            /// 바텀시트 - 앨범에서 사진 선택 탭
            case tapSelectFromAlbumButton
            /// 바텀시트 - 삭제하기 탭
            case tapDeleteProfileImageButton
            /// 생년월일 필드 탭 (DatePicker 표시)
            case tapBirthDateTextField
            /// DatePicker 완료 버튼 탭
            case tapBirthDatePickerDoneButton(Date)
            /// PT 목적 버튼 탭
            case tapPurposeButton(TrainingPurpose)
            /// 팝업 좌측 secondary 버튼 탭
            case tapPopUpSecondaryButton(popUp: PopUp?)
            /// 팝업 우측 primary 버튼 탭
            case tapPopUpPrimaryButton(popUp: PopUp?)
            /// 완료 버튼 탭
            case tapCompleteButton
            /// 네비바 백버튼 탭되었을 때
            case tapNavBackButton
        }

        @CasePathable
        public enum APIAction: Sendable {
            /// 정보 수정 API 호출
            case updateUserInfo
            /// 정보 수정 성공
            case updateUserInfoSuccess
            /// 정보 수정 실패
            case updateUserInfoFailure(Error)
        }

        @CasePathable
        public enum SubFeatureAction: Sendable {
            case photoLibrary(PhotoLibraryFeature.Action)
        }
    }

    @Dependency(\.userUseRepoCase) private var userRepository: UserRepository
    @Dependency(\.dismiss) private var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.photoLibraryState, action: \.subFeature.photoLibrary) {
            PhotoLibraryFeature()
        }

        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .view(let action):
                switch action {
                case .binding(\.view_photoPickerItem):
                    let item: PhotosPickerItem? = state.view_photoPickerItem
                    return .run { [item] send in
                        if let item, let data = try? await item.loadTransferable(type: Data.self) {
                            await send(.imagePicked(data))
                        }
                    }

                case .binding:
                    return .none

                case .onAppear:
                    return .send(.loadExistingImage)

                case .tapBirthDateTextField:
                    state.view_isDatePickerPresented = true
                    return .none

                case .tapBirthDatePickerDoneButton(let date):
                    state.birthDate = date.toString(format: .yyyyMMddSlash)
                    state.view_birthDateStatus = .filled
                    state.view_isDatePickerPresented = false
                    return .none

                case .tapPurposeButton(let purpose):
                    if state.selectedPurposes.contains(purpose) {
                        state.selectedPurposes.removeAll { $0 == purpose }
                    } else {
                        state.selectedPurposes.append(purpose)
                    }
                    return .none

                case .tapProfileImageEditButton:
                    // 바텀시트 표시
                    state.view_isPhotoMenuBottomSheetPresented = true
                    return .none

                case .tapSelectFromAlbumButton:
                    // 바텀시트 닫고 권한 확인
                    state.view_isPhotoMenuBottomSheetPresented = false
                    return .send(.subFeature(.photoLibrary(.requestPermission)))

                case .tapDeleteProfileImageButton:
                    // 바텀시트 닫고 삭제 팝업 표시
                    state.view_isPhotoMenuBottomSheetPresented = false
                    return .send(.setPopUpStatus(TraineeEditMyPageViewReducer.PopUp.deleteProfileImage))

                case .tapPopUpSecondaryButton(let popUp):
                    guard let popUp = popUp else { return .none }

                    switch popUp {
                    case .deleteProfileImage, .photoAuthorization:
                        return .send(.setPopUpStatus(nil))

                    case .endToEditInfo:
                        // "종료" 버튼 - 팝업 닫고 뒤로가기
                        state.view_popUp = nil
                        state.view_isPopUpPresented = false
                        return .run { _ in
                            await self.dismiss()
                        }

                    case .updateFailed:
                        return .send(.setPopUpStatus(nil))
                    }

                case .tapPopUpPrimaryButton(let popUp):
                    guard let popUp else { return .none }

                    switch popUp {
                    case .deleteProfileImage:
                        // 이미지 삭제
                        state.userImageData = nil
                        state.view_photoPickerItem = nil
                        return .send(.setPopUpStatus(nil))

                    case .endToEditInfo:
                        return .send(.setPopUpStatus(nil))

                    case .photoAuthorization:
                        // 설정 화면으로 이동
                        if let url = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                        return .send(.setPopUpStatus(nil))

                    case .updateFailed:
                        // 팝업 닫기
                        return .send(.setPopUpStatus(nil))
                    }

                case .tapCompleteButton:
                    // 완료 버튼 탭 -> API 호출
                    return .send(.api(.updateUserInfo))

                case .tapNavBackButton:
                    // 변경사항이 있으면 확인 팝업 표시, 없으면 바로 뒤로가기
                    if state.hasChanges {
                        return .send(.setPopUpStatus(.endToEditInfo))
                    } else {
                        return .run { _ in
                            await self.dismiss()
                        }
                    }
                }

            case .api(let action):
                switch action {
                case .updateUserInfo:
                    return .run { [state] send in
                        do {
                            // 생년월일 형식 변환: YYYY/MM/DD -> yyyy-MM-dd
                            let birthdayForAPI: String?
                            if !state.birthDate.isEmpty {
                                birthdayForAPI = state.birthDate.replacingOccurrences(of: "/", with: "-")
                            } else {
                                birthdayForAPI = nil
                            }

                            // RequestDTO 생성
                            let reqDTO = UpdateUserInfoRequestDTO(
                                removeImage: state.userImageData == nil && state.existingImageUrl != nil,
                                memberType: "TRAINEE",
                                name: state.userName,
                                birthday: birthdayForAPI,
                                height: Double(state.height),
                                weight: Double(state.weight),
                                cautionNote: state.cautionNote.isEmpty ? nil : state.cautionNote,
                                ptGoals: state.selectedPurposes.map { $0.koreanName }
                            )

                            // API 호출
                            _ = try await userRepository.putUpdateUserInfo(
                                reqDTO,
                                profileImage: state.userImageData
                            )

                            // 성공 시 마이페이지 정보 다시 불러오기 (shared state 자동 업데이트)
                            let _ = try await userRepository.getMyPageInfo()

                            await send(.api(.updateUserInfoSuccess))
                        } catch {
                            await send(.api(.updateUserInfoFailure(error)))
                        }
                    }

                case .updateUserInfoSuccess:
                    // 성공 토스트 표시
                    NotificationCenter.default.post(
                        toast: .init(
                            presentType: .image(.icnCheckMarkGreen),
                            message: "수정한 정보가 저장되었어요"
                        )
                    )

                    // 네비게이션 팝
                    return .run { _ in
                        await self.dismiss()
                    }

                case .updateUserInfoFailure(let error):
                    // 에러 팝업 표시
                    let errorMessage = "정보 수정 중 오류가 발생했어요.\n잠시 후 다시 시도해주세요."
                    return .send(.setPopUpStatus(.updateFailed(errorMessage)))
                }

            case .subFeature(let internalAction):
                switch internalAction {
                case .photoLibrary(.showPermissionPopup):
                    return .send(.setPopUpStatus(TraineeEditMyPageViewReducer.PopUp.photoAuthorization))
                default:
                    return .none
                }

            case .imagePicked(let imgData):
                state.userImageData = imgData
                return .none

            case .loadExistingImage:
                // Shared traineeData에서 모든 데이터 로드
                let traineeData = state.traineeData

                // 기본 정보
                state.userName = traineeData.name
                state.existingImageUrl = traineeData.profileImageUrl
                state.originalImageUrl = traineeData.profileImageUrl

                // 생년월일
                if let birthday = traineeData.birthday, !birthday.isEmpty {
                    state.birthDate = birthday
                    state.originalBirthDate = birthday
                    state.view_birthDateStatus = .filled
                }

                // 키
                if let height = traineeData.height {
                    let heightStr = String(format: "%.1f", height)
                    state.height = heightStr
                    state.originalHeight = heightStr
                    state.view_heightStatus = .filled
                }

                // 몸무게
                if let weight = traineeData.weight {
                    let weightStr = String(format: "%.1f", weight)
                    state.weight = weightStr
                    state.originalWeight = weightStr
                    state.view_weightStatus = .filled
                }

                // 주의사항
                if let cautionNote = traineeData.cautionNote, !cautionNote.isEmpty {
                    state.cautionNote = cautionNote
                    state.originalCautionNote = cautionNote
                    state.view_editorStatus = .filled
                }

                // PT 목적
                let purposes = traineeData.ptGoals.compactMap { TrainingPurpose(koreanName: $0) }
                state.selectedPurposes = purposes
                state.originalPurposes = purposes

                // 프로필 이미지 로드
                if let urlString = state.existingImageUrl,
                   !urlString.isEmpty,
                   state.userImageData == nil,
                   let url = URL(string: urlString) {
                    return .run { send in
                        do {
                            let (data, _) = try await URLSession.shared.data(from: url)
                            await send(.existingImageLoaded(data))
                        } catch {
                            print("Failed to load existing image: \(error)")
                        }
                    }
                }
                return .none

            case .existingImageLoaded(let data):
                // 기존 이미지를 로드한 경우, 현재 이미지와 원본 이미지 모두 설정
                state.userImageData = data
                state.originalImageData = data
                return .none

            case .setPopUpStatus(let popUp):
                state.view_popUp = popUp
                state.view_isPopUpPresented = popUp != nil
                return .none
            }
        }
    }
}

public extension TraineeEditMyPageViewReducer {
    /// 본 화면에 팝업으로 표시되는 목록
    enum PopUp: Equatable, Sendable {
        /// 프로필 이미지를 삭제할까요?
        case deleteProfileImage
        /// 정보 수정을 종료할까요?
        case endToEditInfo
        /// 사진 권한 요청
        case photoAuthorization
        /// 정보 수정 실패
        case updateFailed(String)

        var title: String {
            switch self {
            case .deleteProfileImage:
                return "프로필 이미지를 삭제할까요?"
            case .endToEditInfo:
                return "정보 수정을 종료할까요?"
            case .photoAuthorization:
                return "사진 접근 권한이 필요해요"
            case .updateFailed:
                return "정보 수정 실패"
            }
        }

        var message: String {
            switch self {
            case .deleteProfileImage:
                return "삭제된 이미지는 기본 이미지로 변경돼요"
            case .endToEditInfo:
                return "수정 사항이 저장되지 않아요!"
            case .photoAuthorization:
                return "프로필 사진을 변경하려면 사진 접근 권한이 필요해요"
            case .updateFailed(let message):
                return message
            }
        }

        var showAlertIcon: Bool {
            switch self {
            case .deleteProfileImage, .endToEditInfo, .updateFailed:
                return true
            case .photoAuthorization:
                return false
            }
        }

        var secondaryAction: Action.View? {
            switch self {
            case .deleteProfileImage, .endToEditInfo, .photoAuthorization:
                return .tapPopUpSecondaryButton(popUp: self)
            case .updateFailed:
                return nil
            }
        }

        var primaryAction: Action.View {
            return .tapPopUpPrimaryButton(popUp: self)
        }

        var primaryButtonTitle: String {
            switch self {
            case .deleteProfileImage:
                return "삭제"
            case .endToEditInfo:
                return "계속 수정"
            case .photoAuthorization:
                return "설정으로 이동"
            case .updateFailed:
                return "확인"
            }
        }

        var secondaryButtonTitle: String {
            switch self {
            case .endToEditInfo:
                return "종료"
            default:
                return "취소"
            }
        }
    }
}
