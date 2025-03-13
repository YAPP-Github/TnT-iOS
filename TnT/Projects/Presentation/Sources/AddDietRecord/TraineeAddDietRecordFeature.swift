//
//  TraineeAddDietRecordFeature.swift
//  Presentation
//
//  Created by 박민서 on 2/10/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation
import _PhotosUI_SwiftUI
import ComposableArchitecture

import Domain
import DesignSystem

@Reducer
public struct TraineeAddDietRecordFeature {
    
    public typealias FocusField = TraineeAddDietRecordView.Field
    
    @ObservableState
    public struct State: Equatable {
        // MARK: Data related state
        /// 캘린더에서 선택된 날짜
        var calendarSelectedDate: Date
        /// 식단 날짜
        var dietDate: Date?
        /// 식단 시간
        var dietTime: Date?
        /// 식단 타입
        var dietType: DietType?
        /// 식단 사진
        var dietImageData: Data?
        /// 식단 정보
        var dietInfo: String
        
        // MARK: UI related state
        /// 텍스트 필드 상태 (빈 값 / 입력됨 / 유효하지 않음)
        var view_dietDateStatus: TTextField.Status
        var view_dietTimeStatus: TTextField.Status
        var view_dietInfoStatus: TTextEditor.Status
        /// 현재 포커스된 필드
        var view_focusField: FocusField?
        /// BottomSheet에 표시할 아이템
        var view_bottomSheetItem: BottomSheetItem?
        /// "완료" 버튼 활성화 여부
        var view_isSubmitButtonEnabled: Bool
        /// 현재 선택된 이미지 (PhotosPickerItem)
        var view_photoPickerItem: PhotosPickerItem?
        /// 표시되는 팝업
        var view_popUp: PopUp?
        /// 팝업 표시 여부
        var view_isPopUpPresented: Bool
        
        // MARK: SubFeature state
        var photoLibraryState = PhotoLibraryFeature.State()
        
        public init(
            calendarSelectedDate: Date = .now,
            dietDate: Date? = nil,
            dietTime: Date? = nil,
            dietType: DietType? = nil,
            dietImageData: Data? = nil,
            dietInfo: String = "",
            view_dietDateStatus: TTextField.Status = .empty,
            view_dietTimeStatus: TTextField.Status = .empty,
            view_dietInfoStatus: TTextEditor.Status = .empty,
            view_focusField: FocusField? = nil,
            view_bottomSheetItem: BottomSheetItem? = nil,
            view_isSubmitButtonEnabled: Bool = false,
            view_photoPickerItem: PhotosPickerItem? = nil,
            view_popUp: PopUp? = nil,
            view_isPopUpPresented: Bool = false
        ) {
            self.calendarSelectedDate = calendarSelectedDate
            self.dietDate = dietDate
            self.dietTime = dietTime
            self.dietType = dietType
            self.dietImageData = dietImageData
            self.dietInfo = dietInfo
            self.view_dietDateStatus = view_dietDateStatus
            self.view_dietTimeStatus = view_dietTimeStatus
            self.view_dietInfoStatus = view_dietInfoStatus
            self.view_focusField = view_focusField
            self.view_bottomSheetItem = view_bottomSheetItem
            self.view_isSubmitButtonEnabled = view_isSubmitButtonEnabled
            self.view_photoPickerItem = view_photoPickerItem
            self.view_popUp = view_popUp
            self.view_isPopUpPresented = view_isPopUpPresented
        }
    }
    
    @Dependency(\.traineeRepoUseCase) private var traineeRepoUseCase
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
        /// 팝업 상태 설정
        case setPopUp(PopUp?)
        /// 네비게이션 여부 설정
        case setNavigating
        
        @CasePathable
        public enum View: Sendable, BindableAction {
            /// 바인딩할 액션을 처리
            case binding(BindingAction<State>)
            /// 네비바 백버튼 탭되었을 때
            case tapNavBackButton
            /// 이미지 피커 삭제 버튼 탭되었을 때
            case tapPhotoPickerDeleteButton
            /// 식단 날짜 드롭다운이 탭되었을 때 (DatePicker 표시)
            case tapDietDateDropDown
            /// 식단 시간 드롭다운이 탭되었을 때 (TimePicker 표시)
            case tapDietTimeDropDown
            /// DatePicker / TimePicker 바텀시트에서 날짜를 선택했을 때
            case tapBottomSheetSubmitButton(FocusField, Date)
            /// 식단 타입 버튼이 탭되었을 때
            case tapDietTypeButton(DietType)
            /// "완료" 버튼이 눌렸을 때
            case tapSubmitButton
            /// 팝업 좌측 secondary 버튼 탭
            case tapPopUpSecondaryButton(popUp: PopUp?)
            /// 팝업 우측 primary 버튼 탭
            case tapPopUpPrimaryButton(popUp: PopUp?)
            /// 포커스 상태 변경
            case setFocus(FocusField?, FocusField?)
            /// 화면 표시될 때
            case onAppear
        }
        
        @CasePathable
        public enum APIAction: Sendable {
            /// 식단 등록 API
            case registerDietRecord
        }
        
        @CasePathable
        public enum SubFeatureAction: Sendable {
            case photoLibrary(PhotoLibraryFeature.Action)
        }
    }
    
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
                case .binding(\.dietImageData),
                        .binding(\.dietDate),
                        .binding(\.dietTime),
                        .binding(\.dietType):
                    return self.validateAllFields(&state)
                    
                case .binding(\.dietInfo):
                    state.view_dietInfoStatus = validateDietInfo(state.dietInfo)
                    return self.validateAllFields(&state)
                    
                case .binding(\.view_photoPickerItem):
                    let item: PhotosPickerItem? = state.view_photoPickerItem
                    return .run { [item] send in
                        if let item,
                           let data = try? await item.loadTransferable(type: Data.self) {
                            await send(.imagePicked(data))
                        }
                    }
                    
                case .binding:
                    return .none
                    
                case .tapNavBackButton:
                    if state.dietTime != nil,
                       state.dietType != nil,
                       state.dietInfo.isEmpty == false {
                        return self.setPopUpStatus(&state, status: .cancelDietAdd)
                    } else {
                        return .run { _ in await self.dismiss() }
                    }
                    
                case .tapPhotoPickerDeleteButton:
                    state.dietImageData = nil
                    state.view_photoPickerItem = nil
                    return .none
                    
                case .tapDietDateDropDown:
                    state.view_bottomSheetItem = .datePicker(.dietDate)
                    return .send(.view(.setFocus(state.view_focusField, .dietDate)))
                    
                case .tapDietTimeDropDown:
                    state.view_bottomSheetItem = .timePicker(.dietTime)
                    return .send(.view(.setFocus(state.view_focusField, .dietTime)))
                    
                case let .tapBottomSheetSubmitButton(field, date):
                    state.view_bottomSheetItem = nil
                    
                    switch field {
                    case .dietDate:
                        state.dietDate = date
                        state.view_dietDateStatus = .filled
                    case .dietTime:
                        state.dietTime = date
                        state.view_dietTimeStatus = .filled
                    default:
                        return .none
                    }
                    
                    return .concatenate(
                        .send(.view(.setFocus(field, nil))),
                        self.validateAllFields(&state)
                    )
                    
                case .tapDietTypeButton(let type):
                    state.dietType = type
                    return self.validateAllFields(&state)
                    
                case .tapSubmitButton:
                    return .send(.api(.registerDietRecord))
                    
                case .tapPopUpSecondaryButton(let popUp):
                    guard popUp != nil else { return .none }
                    return setPopUpStatus(&state, status: nil)
                    
                case .tapPopUpPrimaryButton(let popUp):
                    guard let popUp else { return .none }
                    
                    switch popUp {
                    case .dietAdded:
                        return .send(.setNavigating)
                        
                    case .cancelDietAdd:
                        return .concatenate(
                            setPopUpStatus(&state, status: nil),
                            .run { _ in await self.dismiss() }
                        )
                        
                    case .photoAuthorization:
                        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                        return setPopUpStatus(&state, status: nil)
                    }
                    
                case let .setFocus(oldFocus, newFocus):
                    guard oldFocus != newFocus else { return .none }
                    state.view_focusField = newFocus
                    return .none
                    
                case .onAppear:
                    state.dietDate = state.calendarSelectedDate
                    state.view_dietDateStatus = .filled
                    return .none
                }
                
            case .api(let action):
                switch action {
                case .registerDietRecord:
                    guard let date = combinedDietDateTime(date: state.dietDate, time: state.dietTime)?.toString(format: .ISO8601),
                          let dietType = state.dietType?.rawValue else { return .none }
                    return .run { [state] send in
                        let result = try await traineeRepoUseCase.postTraineeDietRecord(
                            .init(
                                date: date,
                                dietType: dietType,
                                memo: state.dietInfo
                            ),
                            imgData: state.dietImageData
                        )
                        await send(.setPopUp(.dietAdded))
                    }
                }
                
            case .subFeature(let internalAction):
                switch internalAction {
                case .photoLibrary(.showPermissionPopup):
                    return setPopUpStatus(&state, status: .photoAuthorization)
                    
                default:
                    return .none
                }
                
            case .imagePicked(let imgData):
                state.dietImageData = imgData
                return self.validateAllFields(&state)
                
            case .setPopUp(let popUp):
                return setPopUpStatus(&state, status: popUp)

            case .setNavigating:
                return .none
            }
        }
    }
}

// MARK: Internal Logic
private extension TraineeAddDietRecordFeature {
    /// 식단 정보 상태 검증
    func validateDietInfo(_ info: String) -> TTextEditor.Status {
        guard !info.isEmpty else { return .empty }
        return info.count > 100 ? .invalid : .filled
    }
    
    /// 모든 필드의 상태를 검증하여 "다음" 버튼 활성화 여부를 결정
    func validateAllFields(_ state: inout State) -> Effect<Action> {
        guard state.dietDate != nil,
              state.dietTime != nil,
              let date = combinedDietDateTime(date: state.dietDate, time: state.dietTime),
              date <= .now,
              state.dietType != nil,
              !state.dietInfo.isEmpty && state.dietInfo.count <= 100
        else {
            state.view_isSubmitButtonEnabled = false
            return .none
        }
        
        state.view_isSubmitButtonEnabled = true
        return .none
    }
    
    /// 팝업 상태, 표시 상태를 업데이트
    /// status nil 입력인 경우 팝업 표시 해제
    func setPopUpStatus(_ state: inout State, status: PopUp?) -> Effect<Action> {
        state.view_popUp = status
        state.view_isPopUpPresented = status != nil
        return .none
    }
    
    /// dietDate와 dietTime을 결합하여 최종 `Date`를 생성
    func combinedDietDateTime(date: Date?, time: Date?) -> Date? {
        guard let date = date, let time = time else { return nil }
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        return calendar.date(from: DateComponents(
            year: dateComponents.year,
            month: dateComponents.month,
            day: dateComponents.day,
            hour: timeComponents.hour,
            minute: timeComponents.minute,
            second: timeComponents.second
        ))
    }
}

// MARK: BottomSheet
public extension TraineeAddDietRecordFeature {
    enum BottomSheetItem: Equatable, Identifiable {
        case datePicker(FocusField)
        case timePicker(FocusField)
        
        public var id: String {
            switch self {
            case .datePicker(let field):
                return "datePicker" + field.title
            case .timePicker(let field):
                return "timePicker" + field.title
            }
        }
        
        public var field: FocusField? {
            switch self {
            case .datePicker(let field):
                return field
            case .timePicker(let field):
                return field
            }
        }
    }
}

// MARK: PopUp
public extension TraineeAddDietRecordFeature {
    /// 본 화면에 팝업으로 표시되는 목록
    enum PopUp: Equatable, Sendable {
        /// 식단을 기록했어요!
        case dietAdded
        /// 식단 기록을 종료할까요?
        case cancelDietAdd
        /// 사진 접근 권한이 필요해요
        case photoAuthorization
        
        var title: String {
            switch self {
            case .dietAdded:
                return "식단을 기록했어요!"
            case .cancelDietAdd:
                return "식단 기록을 종료할까요?"
            case .photoAuthorization:
                return "식단 사진 설정을 위해\n사진 접근 권한이 필요해요"
            }
        }
        
        var message: String {
            switch self {
            case .dietAdded:
                return "내일도 기록해 주실 거죠?"
            case .cancelDietAdd:
                return "기록이 저장되지 않아요!"
            case .photoAuthorization:
                return "‘TnT'는 프로필 사진 설정, 운동 기록 및 식단 기록 저장 등 주요 기능 제공을 위해 사진 접근 권한이 필요합니다.\n설정에서 권한을 활성화해주세요."
            }
        }
        
        var showAlertIcon: Bool {
            switch self {
            case .dietAdded, .photoAuthorization:
                return false
            case .cancelDietAdd:
                return true
            }
        }
        
        var secondaryAction: Action.View? {
            switch self {
            case .dietAdded:
                return nil
            case .cancelDietAdd, .photoAuthorization:
                return .tapPopUpSecondaryButton(popUp: self)
            }
        }
        
        var primaryAction: Action.View {
            return .tapPopUpPrimaryButton(popUp: self)
        }
    }
}
