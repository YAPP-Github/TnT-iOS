//
//  TraineeEditMyPageView.swift
//  Presentation
//
//  Created by 박서연 on 11/18/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

import Domain
import DesignSystem

@ViewAction(for: TraineeEditMyPageViewReducer.self)
public struct TraineeEditMyPageView: View {

    @Bindable public var store: StoreOf<TraineeEditMyPageViewReducer>
    @FocusState private var focusedField: Field?

    public init(store: StoreOf<TraineeEditMyPageViewReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            Navigationbar

            ScrollView {
                VStack(spacing: 32) {
                    ImageSection()
                        .padding(.top, 20)

                    VStack(spacing: 48) {
                        NameSection()
                        BasicInfoSection()
                        TrainingPurposeSection()
                        PrecautionSection()
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }

            Spacer()
        }
        .onAppear {
            send(.onAppear)
        }
        .navigationBarBackButtonHidden()
        .keyboardDismissOnTap()
        .bottomFixWith {
            TBottomButton(
                title: "완료",
                isEnable: store.hasChanges
            ) {
                send(.tapCompleteButton)
            }
            .padding(.bottom, .safeAreaBottom)
        }
        .tPopUp(isPresented: $store.view_isPopUpPresented) {
            PopUpView()
        }
        .sheet(isPresented: $store.view_isPhotoMenuBottomSheetPresented) {
            PhotoMenuBottomSheet()
                .presentationDetents([.height(160)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $store.view_isDatePickerPresented) {
            TDatePickerView(
                calendarType: .system(in: ...Date().addingTimeInterval(-86400)),
                selectedDate: store.birthDate.toDate(format: .yyyyMMddSlash) ?? Date(timeIntervalSince1970: 0),
                title: "생년월일",
                monthFormatter: {
                    TDateFormatUtility.formatter(for: .yyyy년_MM월).string(from: $0)
                }
            ) { date in
                send(.tapBirthDatePickerDoneButton(date))
            }
            .autoSizingBottomSheet(presentationDragIndicator: .hidden)
            .interactiveDismissDisabled(true)
        }
    }
}

public extension TraineeEditMyPageView {
    enum Field: Sendable, Hashable {
        case birthDate
        case height
        case weight
        case cautionNote
    }
}

private extension TraineeEditMyPageView {
    var Navigationbar: some View {
        TNavigation(
            type: .LButtonWithTitle(
                leftImage: .icnArrowLeft,
                centerTitle: "내 정보 수정"
            ),
            leftAction: {
                // TODO: 뒤로 가기 네비게이션 구현
                print("뒤로 가기")
            }
        )
    }

    @ViewBuilder
    private func ImageSection() -> some View {
        VStack(spacing: 12) {
            // 프로필 이미지
            Group {
                if let imageData = store.userImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                } else {
                    // 기본 이미지 (트레이니)
                    Image(.imgDefaultTraineeImage)
                        .resizable()
                        .clipShape(Circle())
                }
            }
            .frame(width: 132, height: 132)
            .overlay(alignment: .bottomTrailing) {
                // 이미지 변경 버튼 - 바텀시트 띄우기
                Button {
                    send(.tapProfileImageEditButton)
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.neutral900)

                        Image(.icnWriteWhite)
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                }
                .frame(width: 28, height: 28)
            }
        }
    }

    @ViewBuilder
    private func NameSection() -> some View {
        TTextField(
            placeholder: "닉네임을 입력해주세요",
            text: Binding(
                get: { store.userName },
                set: { _ in }
            ),
            textFieldStatus: .constant(.filled)
        )
        .withSectionLayout(
            header: .init(
                isRequired: false,
                title: "이름",
                limitCount: 15,
                textCount: store.userName.count
            )
        )
        .disabled(true) // 이름은 수정 불가
    }

    @ViewBuilder
    private func BasicInfoSection() -> some View {
        VStack(spacing: 48) {
            // 생년월일
            TTextField(
                placeholder: "YYYY/MM/DD",
                text: $store.birthDate,
                textFieldStatus: $store.view_birthDateStatus
            )
            .withSectionLayout(header: .init(isRequired: false, title: "생년월일", limitCount: nil, textCount: nil))
            .focused($focusedField, equals: .birthDate)
            .allowsHitTesting(false)
            .overlay(
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { send(.tapBirthDateTextField) }
            )

            // 키 / 몸무게
            HStack(spacing: 12) {
                TTextField(
                    placeholder: "0",
                    text: $store.height,
                    textFieldStatus: $store.view_heightStatus,
                    rightView: {
                        TTextField.RightView(style: .unit(text: "cm", status: store.view_heightStatus))
                    }
                )
                .withSectionLayout(
                    header: .init(isRequired: false, title: "키", limitCount: nil, textCount: nil),
                    footer: .init(footerText: "잘못된 수치를 입력했어요", status: store.view_heightStatus)
                )
                .focused($focusedField, equals: .height)
                .keyboardType(.decimalPad)

                TTextField(
                    placeholder: "0",
                    text: $store.weight,
                    textFieldStatus: $store.view_weightStatus,
                    rightView: {
                        TTextField.RightView(style: .unit(text: "kg", status: store.view_weightStatus))
                    }
                )
                .withSectionLayout(
                    header: .init(isRequired: false, title: "몸무게", limitCount: nil, textCount: nil),
                    footer: .init(footerText: "잘못된 수치를 입력했어요", status: store.view_weightStatus)
                )
                .focused($focusedField, equals: .weight)
                .keyboardType(.decimalPad)
            }
        }
    }

    @ViewBuilder
    private func TrainingPurposeSection() -> some View {
        let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

        VStack(alignment: .leading, spacing: 16) {
            Text("PT 목적")
                .typographyStyle(.body1Bold, with: .neutral950)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(TrainingPurpose.allCases, id: \.self) { purpose in
                    TButton(
                        title: purpose.koreanName,
                        config: .xLarge,
                        state: store.selectedPurposes.contains(purpose)
                        ? .default(.red(isEnabled: true))
                        : .default(.outline(isEnabled: true)),
                        action: {
                            send(.tapPurposeButton(purpose))
                        }
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func PrecautionSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("주의사항")
                .typographyStyle(.body1Bold, with: .neutral950)

            TTextEditor(
                placeholder: "트레이너가 꼭 알아야할 주의사항을 입력해주세요",
                text: $store.cautionNote,
                textEditorStatus: $store.view_editorStatus,
                footer: {
                    .init(
                        textLimit: store.view_editorMaxCount ?? 100,
                        status: $store.view_editorStatus,
                        textCount: store.cautionNote.count
                    )
                }
            )
            .focused($focusedField, equals: .cautionNote)
        }
    }

    @ViewBuilder
    private func PhotoMenuBottomSheet() -> some View {
        VStack(spacing: 0) {
            // 앨범에서 사진 선택
            PhotosPicker(
                selection: $store.view_photoPickerItem,
                matching: .images
            ) {
                HStack {
                    Text("앨범에서 사진 선택")
                        .typographyStyle(.body1Medium, with: .neutral950)
                    Spacer()
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(Color.common0)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onTapGesture {
                // 권한 확인
                send(.tapSelectFromAlbumButton)
            }

            Button {
                send(.tapDeleteProfileImageButton)
            } label: {
                HStack {
                    Text("삭제하기")
                        .typographyStyle(.body1Medium, with: .neutral950)
                    Spacer()
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(Color.common0)
            }
        }
        .background(Color.common0)
    }

    @ViewBuilder
    private func PopUpView() -> some View {
        if let popUp = store.view_popUp {
            let buttons: [TPopupAlertState.ButtonState] = [
                popUp.secondaryAction.map { action in
                    .init(
                        title: popUp.secondaryButtonTitle,
                        style: .secondary,
                        action: .init(action: { send(action) })
                    )
                },
                .init(
                    title: popUp.primaryButtonTitle,
                    style: .primary,
                    action: .init(action: { send(popUp.primaryAction) })
                )
            ].compactMap { $0 }

            TPopUpAlertView(
                alertState: .init(
                    title: popUp.title,
                    message: popUp.message,
                    showAlertIcon: popUp.showAlertIcon,
                    buttons: buttons
                )
            )
        } else {
            EmptyView()
        }
    }
}


import Foundation
import Photos
import _PhotosUI_SwiftUI
import ComposableArchitecture

import Domain
import DesignSystem
import UserNotifications
import UIKit

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
                    case .deleteProfileImage, .endToEditInfo, .photoAuthorization:
                        return .send(.setPopUpStatus(nil))
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
                }

            case .api(let action):
                switch action {
                case .updateUserInfo:
                    return .run { [state] send in
                        do {
                            // RequestDTO 생성
                            let reqDTO = UpdateUserInfoRequestDTO(
                                removeImage: state.userImageData == nil && state.existingImageUrl != nil,
                                memberType: "TRAINEE",
                                name: state.userName,
                                birthday: state.birthDate.isEmpty ? nil : state.birthDate,
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
                return "종료"
            case .photoAuthorization:
                return "설정으로 이동"
            case .updateFailed:
                return "확인"
            }
        }

        var secondaryButtonTitle: String {
            return "취소"
        }
    }
}
