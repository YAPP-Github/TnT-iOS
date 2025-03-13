//
//  TrainerAddPTSessionFeature.swift
//  Presentation
//
//  Created by 박민서 on 2/6/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation
import ComposableArchitecture

import Domain
import DesignSystem

@Reducer
public struct TrainerAddPTSessionFeature {
    
    public typealias FocusField = TrainerAddPTSessionView.Field
    
    @ObservableState
    public struct State: Equatable {
        // MARK: Data related state
        /// 캘린더에서 선택된 날짜
        var calendarSelectedDate: Date
        /// 트레이너 회원 목록
        var traineeList: [TraineeListItemEntity]
        /// 선택된 회원
        var trainee: TraineeListItemEntity?
        /// PT 날짜
        var ptDate: Date?
        /// 시작 시간
        var startTime: Date?
        /// 종료 시간
        var endTime: Date?
        /// 메모
        var memo: String
        
        // MARK: UI related state
        /// 텍스트 필드 상태 (빈 값 / 입력됨 / 유효하지 않음)
        var view_traineeStatus: TTextField.Status
        var view_ptDateStatus: TTextField.Status
        var view_startTimeStatus: TTextField.Status
        var view_endTimeStatus: TTextField.Status
        var view_memoStatus: TTextEditor.Status
        /// 현재 포커스된 필드
        var view_focusField: FocusField?
        /// BottomSheet에 표시할 아이템
        var view_bottomSheetItem: BottomSheetItem?
        /// "완료" 버튼 활성화 여부
        var view_isSubmitButtonEnabled: Bool
        /// 표시되는 팝업
        var view_popUp: PopUp?
        /// 팝업 표시 여부
        var view_isPopUpPresented: Bool
        /// 시작 시간-종료 시간 간 시간 간격
        var view_sessionTime: Int? {
            guard let startTime, let endTime else { return nil }
            let minuteDifference = Calendar.current.dateComponents([.minute], from: startTime, to: endTime).minute ?? 0
            return minuteDifference
        }
        
        public init(
            calendarSelectedDate: Date = .now,
            traineeList: [TraineeListItemEntity] = [],
            trainee: TraineeListItemEntity? = nil,
            ptDate: Date? = nil,
            startTime: Date? = nil,
            endTime: Date? = nil,
            memo: String = "",
            view_traineeStatus: TTextField.Status = .empty,
            view_ptDateStatus: TTextField.Status = .empty,
            view_startTimeStatus: TTextField.Status = .empty,
            view_endTimeStatus: TTextField.Status = .empty,
            view_memoStatus: TTextEditor.Status = .empty,
            view_focusField: FocusField? = nil,
            view_bottomSheetItem: BottomSheetItem? = nil,
            view_isSubmitButtonEnabled: Bool = false,
            view_popUp: PopUp? = nil,
            view_isPopUpPresented: Bool = false
        ) {
            self.calendarSelectedDate = calendarSelectedDate
            self.traineeList = traineeList
            self.trainee = trainee
            self.ptDate = ptDate
            self.startTime = startTime
            self.endTime = endTime
            self.memo = memo
            self.view_traineeStatus = view_traineeStatus
            self.view_ptDateStatus = view_ptDateStatus
            self.view_startTimeStatus = view_startTimeStatus
            self.view_endTimeStatus = view_endTimeStatus
            self.view_memoStatus = view_memoStatus
            self.view_focusField = view_focusField
            self.view_bottomSheetItem = view_bottomSheetItem
            self.view_isSubmitButtonEnabled = view_isSubmitButtonEnabled
            self.view_popUp = view_popUp
            self.view_isPopUpPresented = view_isPopUpPresented
        }
    }
    
    @Dependency(\.trainerRepoUseCase) private var trainerRepoUseCase
    @Dependency(\.dismiss) private var dismiss
    
    public enum Action: Sendable, ViewAction {
        /// 뷰에서 발생한 액션을 처리합니다.
        case view(View)
        /// api 콜 액션을 처리합니다
        case api(APIAction)
        /// 현재 관리 회원 목록 설정
        case setTraineeList([TraineeListItemEntity])
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
            /// 회원 선택 드롭다운이 탭되었을 때 (DatePicker 표시)
            case tapTraineeDropDown
            /// PT 날짜 드롭다운이 탭되었을 때 (DatePicker 표시)
            case tapPtDateDropDown
            /// 시작 시간 드롭다운이 탭되었을 때 (DatePicker 표시)
            case tapStartTimeDropDown
            /// 종료 시간 드롭다운이 탭되었을 때 (DatePicker 표시)
            case tapEndTimeDropDown
            /// TraineeList 바텀시트에서 Trainee를 선택했을 때
            case tapTraineeAtBottomSheet(TraineeListItemEntity)
            /// DatePicker / TimePicker 바텀시트에서 날짜를 선택했을 때
            case tapBottomSheetSubmitButton(FocusField, Date)
            /// 수업 시간 Interval 버튼 눌렀을 때
            case tapSessionIntervalButton(SessionTime)
            /// "완료" 버튼이 눌렸을 때
            case tapSubmitButton
            /// 팝업 좌측 secondary 버튼 탭
            case tapPopUpSecondaryButton(popUp: PopUp?)
            /// 팝업 우측 primary 버튼 탭
            case tapPopUpPrimaryButton(popUp: PopUp?)
            /// 포커스 상태 변경
            case setFocus(FocusField?, FocusField?)
            /// 화면이 표시될 때
            case onAppear
        }
        
        @CasePathable
        public enum APIAction: Sendable {
            /// 관리 회원 목록 API
            case getTraineeList
            /// 수업 등록 API
            case registerPTSession
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        Reduce { state, action in
            switch action {
            case .view(let action):
                switch action {
                case .binding(\.memo):
                    state.view_memoStatus = validateMemo(state.memo)
                    return self.validateAllFields(&state)
                    
                case .binding:
                    return .none
                    
                case .tapNavBackButton:
                    if state.view_isSubmitButtonEnabled {
                        return self.setPopUpStatus(&state, status: .cancelSessionAdd)
                    } else {
                        return .run { send in
                            await self.dismiss()
                        }
                    }
                    
                case .tapTraineeDropDown:
                    state.view_bottomSheetItem = .traineeList
                    return .send(.view(.setFocus(state.view_focusField, .trainee)))
                    
                case .tapPtDateDropDown:
                    state.view_bottomSheetItem = .datePicker(.ptDate)
                    return .send(.view(.setFocus(state.view_focusField, .ptDate)))
                    
                case .tapStartTimeDropDown:
                    state.view_bottomSheetItem = .timePicker(.startTime)
                    return .send(.view(.setFocus(state.view_focusField, .startTime)))
                    
                case .tapEndTimeDropDown:
                    state.view_bottomSheetItem = .timePicker(.endTime)
                    return .send(.view(.setFocus(state.view_focusField, .endTime)))
                    
                case .tapTraineeAtBottomSheet(let item):
                    state.view_bottomSheetItem = nil
                    state.trainee = item
                    state.view_traineeStatus = .filled
                    return .concatenate(
                        .send(.view(.setFocus(.trainee, nil))),
                        self.validateAllFields(&state)
                    )
                    
                case let .tapBottomSheetSubmitButton(field, date):
                    state.view_bottomSheetItem = nil
                    
                    switch field {
                    case .ptDate:
                        state.ptDate = date
                        state.view_ptDateStatus = .filled
                    case .startTime,
                            .endTime:
                        updateTime(state: &state, field: field, with: date)
                    default:
                        return .none
                    }
                    
                    return .concatenate(
                        .send(.view(.setFocus(field, nil))),
                        self.validateAllFields(&state)
                    )
                    
                case .tapSessionIntervalButton(let sessionTime):
                    let interval: Int = sessionTime.rawValue
                    
                    if let startTime = state.startTime,
                       let endTime = Calendar.current.date(byAdding: .minute, value: interval, to: startTime) {
                        updateTime(state: &state, field: .endTime, with: endTime)
                    }
                    
                    return self.validateAllFields(&state)
                    
                case .tapSubmitButton:
                    return .send(.api(.registerPTSession))
                    
                case .tapPopUpSecondaryButton(let popUp):
                    guard popUp != nil else { return .none }
                    return .concatenate(
                        setPopUpStatus(&state, status: nil),
                        .send(.setNavigating)
                    )
                    
                case .tapPopUpPrimaryButton(let popUp):
                    guard popUp != nil else { return .none }
                    return popUp == .sessionAdded
                    ? .send(.setNavigating)
                    : setPopUpStatus(&state, status: nil)
                    
                case let .setFocus(oldFocus, newFocus):
                    state.view_focusField = newFocus
                    return .none
                    
                case .onAppear:
                    state.ptDate = state.calendarSelectedDate
                    state.view_ptDateStatus = .filled
                    return .send(.api(.getTraineeList))
                }
                
            case .api(let action):
                switch action {
                case .getTraineeList:
                    return .run { send in
                        let result = try await trainerRepoUseCase.getActiveTraineesList()
                        let trainees: [TraineeListItemEntity] = result.trainees.map { $0.toEntity() }
                        await send(.setTraineeList(trainees))
                    }
                    
                case .registerPTSession:
                    guard let startDate = combinedDietDateTime(date: state.ptDate, time: state.startTime)?.toString(format: .ISO8601),
                          let endDate = combinedDietDateTime(date: state.ptDate, time: state.endTime)?.toString(format: .ISO8601),
                          let traineeId = state.trainee?.id
                    else { return .none }
                    
                    return .run { send in
                        let _ = try await trainerRepoUseCase.postLesson(
                            reqDTO: .init(
                                start: startDate,
                                end: endDate,
                                traineeId: traineeId
                            )
                        )
                        await send(.setPopUp(.sessionAdded))
                    }
                }
                
            case .setTraineeList(let trainees):
                state.traineeList = trainees
                return .none
                
            case .setPopUp(let popUp):
                return setPopUpStatus(&state, status: popUp)
                
            case .setNavigating:
                return .none
            }
        }
    }
}

// MARK: Internal Logic
private extension TrainerAddPTSessionFeature {
    /// 메모 필드 상태 검증
    func validateMemo(_ memo: String) -> TTextEditor.Status {
        guard !memo.isEmpty else { return .empty }
        return memo.count > 30 ? .invalid : .filled
    }
    
    /// 시작 시간 종료 시간 필드 상태 검증
    func validateTimes(startTime: Date?, endTime: Date?) -> TTextField.Status? {
        guard let startTime, let endTime else { return nil }
        return startTime < endTime ? .filled : .invalid
    }
    
    /// 시작시간 종료시간 업데이트
    func updateTime(
        state: inout State,
        field: FocusField,
        with date: Date
    ) {
        switch field {
        case .startTime:
            state.startTime = date
            state.view_startTimeStatus = .filled
            // 시작 시간 선택시 종료시간 초기화
            state.endTime = nil
            state.view_endTimeStatus = .empty
        case .endTime:
            state.endTime = date
            state.view_endTimeStatus = .filled
        default:
            return
        }
        
        if let start = state.startTime, let end = state.endTime,
           let status = self.validateTimes(startTime: start, endTime: end) {
            state.view_startTimeStatus = status
            state.view_endTimeStatus = status
        }
    }
    
    /// 모든 필드의 상태를 검증하여 "다음" 버튼 활성화 여부를 결정
    func validateAllFields(_ state: inout State) -> Effect<Action> {
        state.view_isSubmitButtonEnabled = false
        
        guard state.trainee != nil && state.ptDate != nil && state.startTime != nil && state.endTime != nil else { return .none }
        
        guard let status = self.validateTimes(startTime: state.startTime, endTime: state.endTime), status == .filled else { return .none }
        
        let memoStatus = self.validateMemo(state.memo)
        guard memoStatus == .filled || memoStatus == .empty else { return .none }
        
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
    
    /// date와 time을 결합하여 최종 `Date`를 생성
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
public extension TrainerAddPTSessionFeature {
    enum BottomSheetItem: Equatable, Identifiable {
        case traineeList
        case datePicker(FocusField)
        case timePicker(FocusField)
        
        public var id: String {
            switch self {
            case .traineeList:
                return "traineeList"
            case .datePicker(let field):
                return "datePicker" + field.title
            case .timePicker(let field):
                return "timePicker" + field.title
            }
        }
        
        public var field: FocusField? {
            switch self {
            case .traineeList:
                return nil
            case .datePicker(let field):
                return field
            case .timePicker(let field):
                return field
            }
        }
    }
    
    enum SessionTime: Int, CaseIterable, Sendable {
        case fourtyMin = 40
        case fiftyMin = 50
        case sixtyMin = 60
        case seventyMin = 70
        case eightyMin = 80
        case ninetyMin = 90
    }
}

// MARK: PopUp
public extension TrainerAddPTSessionFeature {
    /// 본 화면에 팝업으로 표시되는 목록
    enum PopUp: Equatable, Sendable {
        /// 수업 일정이 추가됐어요
        case sessionAdded
        /// 수업 등록을 취소할까요?
        case cancelSessionAdd
        
        var title: String {
            switch self {
            case .sessionAdded:
                return "수업 일정이 추가됐어요"
            case .cancelSessionAdd:
                return "수업 등록을 취소할까요?"
            }
        }
        
        var message: String {
            switch self {
            case .sessionAdded:
                return "등록된 일정은 트레이니에게도 표시돼요!"
            case .cancelSessionAdd:
                return "일정이 저장되지 않아요"
            }
        }
        
        var showAlertIcon: Bool {
            switch self {
            case .cancelSessionAdd:
                return true
            case .sessionAdded:
                return false
            }
        }
        
        var secondaryAction: Action.View? {
            switch self {
            case .cancelSessionAdd:
                return .tapPopUpSecondaryButton(popUp: self)
            case .sessionAdded:
                return nil
            }
        }
        
        var primaryTitle: String {
            switch self {
            case .sessionAdded:
                return "확인"
            case .cancelSessionAdd:
                return "계속 수정"
            }
        }
        
        var primaryAction: Action.View {
            return .tapPopUpPrimaryButton(popUp: self)
        }
    }
}
