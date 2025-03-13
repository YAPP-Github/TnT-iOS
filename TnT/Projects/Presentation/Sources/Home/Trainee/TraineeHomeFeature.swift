//
//  TraineeHomeFeature.swift
//  Presentation
//
//  Created by 박민서 on 2/2/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import Foundation
import ComposableArchitecture

import Domain

@Reducer
public struct TraineeHomeFeature {
    
    @ObservableState
    public struct State: Equatable {
        // MARK: Data related state
        /// 3일 동안 보지 않기 시작 날짜
        @Shared(.appStorage(AppStorage.hideHomePopupUntil)) var hidePopupUntil: Date?
        /// 트레이너 연결 여부
        @Shared(.appStorage(AppStorage.isConnected)) var isConnected: Bool = false
        /// 선택된 날짜
        var selectedDate: Date
        /// 캘린더 이벤트
        var events: [Date: Int]
        /// 수업 정보
        var sessionInfo: WorkoutListItemEntity?
        /// 기록 정보 목록
        var records: [RecordListItemEntity]
        /// 3일 동안 보지 않기 선택되었는지 여부
        var isHideUntilSelected: Bool
        /// API 로드된 년/달 집합
        var loadedMonths: Set<String> = []
        
        // MARK: UI related state
        /// 캘린더 표시 페이지
        var view_currentPage: Date
        /// 수업 카드 시간 표시
        var view_sessionCardTimeString: String {
            guard let sessionInfo,
                  let startDate = sessionInfo.startDate?.toString(format: .a_HHmm),
                  let endDate = sessionInfo.endDate?.toString(format: .a_HHmm)
            else { return "" }
            
            return "\(startDate) ~ \(endDate)"
        }
        /// 기록 제목 표시
        var view_recordTitleString: String {
            return TDateFormatUtility.formatter(for: .MM월_dd일_EEEE).string(from: selectedDate)
        }
        /// 선택 바텀 시트 표시
        var view_isBottomSheetPresented: Bool
        /// 팝업 표시 여부
        var view_isPopUpPresented: Bool
        
        public init(
            selectedDate: Date = .now,
            events: [Date: Int] = [:],
            sessionInfo: WorkoutListItemEntity? = nil,
            records: [RecordListItemEntity] = [],
            isHideUntilSelected: Bool = false,
            view_currentPage: Date = .now,
            view_isBottomSheetPresented: Bool = false,
            view_isPopUpPresented: Bool = false
        ) {
            self.selectedDate = selectedDate
            self.events = events
            self.sessionInfo = sessionInfo
            self.records = records
            self.isHideUntilSelected = isHideUntilSelected
            self.view_currentPage = view_currentPage
            self.view_isBottomSheetPresented = view_isBottomSheetPresented
            self.view_isPopUpPresented = view_isPopUpPresented
        }
    }
    
    @Dependency(\.userUseRepoCase) private var userUseRepoCase: UserRepository
    @Dependency(\.traineeUseCase) private var traineeUseCase: TraineeUseCase
    @Dependency(\.traineeRepoUseCase) private var traineeRepoUseCase: TraineeRepository
    
    public enum Action: Equatable, Sendable, ViewAction {
        /// 뷰에서 발생한 액션을 처리합니다.
        case view(View)
        /// api 콜 액션 처리
        case api(APIAction)
        /// 새로운 이벤트 추가
        case updateEvents([Date: Int])
        /// 해당 날짜 수업/기록 표시
        case setContent(session: WorkoutListItemEntity?, records: [RecordListItemEntity])
        /// 팝업 표시 처리
        case showPopUp
        /// 화면이 표시될 때 - 세션 체크 이후
        case onAppearAfterSessionCheck(isConnected: Bool)
        /// 네비게이션 여부 설정
        case setNavigating(RoutingScreen)
        
        @CasePathable
        public enum View: Equatable, Sendable, BindableAction {
            /// 바인딩할 액션을 처리
            case binding(BindingAction<State>)
            /// 우측 상단 알림 페이지 보기 버튼 탭
            case tapAlarmPageButton
            /// 상단 수업 기록 보기 버튼 탭
            case tapShowSessionRecordButton(id: Int)
            /// 기록 목록 피드백 보기 버튼 탭
            case tapShowRecordFeedbackButton(id: Int)
            /// 기록 아이템 탭
            case tapRecordItem(type: RecordType?, id: Int)
            /// 우측 하단 기록 추가 버튼 탭
            case tapAddRecordButton
            /// 개인 운동 기록 추가 버튼 탭
            case tapAddWorkoutRecordButton
            /// 식단 기록 추가 버튼 탭
            case tapAddDietRecordButton
            /// 연결 권장 팝업 - 다음에 버튼 탭
            case tapPopUpNextButton
            /// 연결 권장 팝업 - 3일 동안 보지 않기 버튼 탭
            case tapPopUpDontShowUntilThreeDaysButton(Bool)
            /// 연결 권장 팝업 - 연결하기 버튼 탭
            case tapPopUpConnectButton
            /// 화면이 표시될 때
            case onAppear
        }
        
        @CasePathable
        public enum APIAction: Equatable, Sendable {
            /// 캘린더 수업 기록 존재하는 날짜 조회
            case getActiveDateList(startDate: Date, endDate: Date)
            /// 캘린더 특정 날짜 수업/기록 조회
            case getActiveDateDetail(date: Date)
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        Reduce { state, action in
            switch action {
                
            case .view(let action):
                switch action {
                case .binding(\.selectedDate):
                    return .send(.api(.getActiveDateDetail(date: state.selectedDate)))
                    
                case .binding(\.view_currentPage):
                    return self.currentPageUpdated(state: &state)
                    
                case .binding:
                    return .none
                    
                case .tapAlarmPageButton:
                    return .send(.setNavigating(.alarmPage))
                    
                case .tapShowSessionRecordButton(let id):
                    // TODO: 네비게이션 연결 시 추가
                    print("tapShowSessionRecordButton \(id)")
                    return .none
                    
                case .tapShowRecordFeedbackButton(let id):
                    // TODO: 네비게이션 연결 시 추가
                    print("tapShowRecordFeedbackButton \(id)")
                    return .none
                    
                case let .tapRecordItem(recordType, id):
                    switch recordType {
                    case .diet:
                        return .send(.setNavigating(.dietDetailPage(id: id)))
                    default:
                        return .none
                    }
                    
                case .tapAddRecordButton:
                    state.view_isBottomSheetPresented = true
                    return .none
                    
                case .tapAddWorkoutRecordButton:
                    // TODO: 네비게이션 연결 시 추가
                    print("tapAddWorkoutRecordButton")
                    return .none
                    
                case .tapAddDietRecordButton:
                    state.view_isBottomSheetPresented = false
                    return .send(.setNavigating(.addDietRecordPage(selectedDate: state.selectedDate)))
                    
                case .tapPopUpNextButton:
                    if state.isHideUntilSelected {
                        state.$hidePopupUntil.withLock {
                            $0 = Calendar.current.date(byAdding: .day, value: 3, to: Date())
                        }
                    }
                    state.view_isPopUpPresented = false
                    return .none
                    
                case .tapPopUpDontShowUntilThreeDaysButton(let isHidden):
                    state.isHideUntilSelected = isHidden
                    return .none
                    
                case .tapPopUpConnectButton:
                    if state.isHideUntilSelected {
                        state.$hidePopupUntil.withLock {
                            $0 = Calendar.current.date(byAdding: .day, value: 3, to: Date())
                        }
                    }
                    state.view_isPopUpPresented = false
                    return .send(.setNavigating(.traineeInvitationCodeInput))
                    
                case .onAppear:
                    return .run { send in
                        if let result = try? await userUseRepoCase.getSessionCheck() {
                            await send(.onAppearAfterSessionCheck(isConnected: result.isConnected))
                        }
                    }
                }
                
            case .api(let action):
                switch action {
                case let .getActiveDateList(startDate, endDate):
                    let startDate = startDate.toString(format: .yyyyMMdd)
                    let endDate = endDate.toString(format: .yyyyMMdd)
                    
                    return .run { send in
                        let result = try await traineeRepoUseCase.getActiveDateList(startDate: startDate, endDate: endDate)
                        
                        let newEvents: [Date: Int] = result.ptLessonDates.reduce(into: [:]) { events, dateString in
                            if let date = dateString.toDate(format: .yyyyMMdd) {
                                events[date] = 1
                            }
                        }
                        
                        await send(.updateEvents(newEvents))
                    }
                    
                case .getActiveDateDetail(let date):
                    let date = date.toString(format: .yyyyMMdd)
                    return .run { send in
                        let result = try await traineeRepoUseCase.getActiveDateDetail(date: date)
                        let sessionInfo = result.ptInfo?.toEntity()
                        let recordsInfo = result.diets.map { $0.toEntity() }
                        
                        await send(.setContent(session: sessionInfo, records: recordsInfo))
                    }
                }
                
            case .updateEvents(let newEvents):
                state.events.merge(newEvents) { _, new in new }
                return .none
                
            case let .setContent(sessionInfo, records):
                state.sessionInfo = sessionInfo
                state.records = records
                return .none
                
            case .showPopUp:
                let hideUntil = state.hidePopupUntil ?? Date()
                let hidePopUp = state.isConnected || hideUntil > Date()
                state.view_isPopUpPresented = !hidePopUp
                return .none
                
            case .onAppearAfterSessionCheck(let isConnected):
                state.$isConnected.withLock { $0 = isConnected }
                return .concatenate(
                    .send(.showPopUp),
                    currentPageUpdated(state: &state),
                    .send(.api(.getActiveDateDetail(date: state.selectedDate)))
                )
                
            case .setNavigating:
                return .none
            }
        }
    }
}

extension TraineeHomeFeature {
    /// view\_currentPage가 업데이트 되었을 때 호출됩니다
    /// 달이 변경되는 경우 새로운 달력 데이터를 불러오기 위한 API를 호출합니다
    func currentPageUpdated(state: inout State) -> Effect<Action> {
        let newPage = state.view_currentPage
        let newMonth = newPage.toString(format: .yyyyMM)

        // 이전에 불러온 년/달과 같은 경우 API 호출 생략
//        guard !state.loadedMonths.contains(newMonth) else { return .none }
//            state.loadedMonths.insert(newMonth)


        // API 호출할 범위 설정
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: newPage)
        guard let firstDayOfMonth = calendar.date(from: components),
              let startDate = calendar.date(byAdding: DateComponents(month: -1, day: 20), to: firstDayOfMonth),
              let endDate = calendar.date(byAdding: DateComponents(month: 1, day: 7), to: firstDayOfMonth)
        else {
            return .none
        }

        return .send(.api(.getActiveDateList(startDate: startDate, endDate: endDate)))
    }
}

extension TraineeHomeFeature {
    public enum RoutingScreen: Equatable, Sendable {
        /// 알림 페이지
        case alarmPage
        /// 수업 기록 상세 페이지
        case sessionRecordPage
        /// 기록 피드백 페이지
        case recordFeedbackPage
        /// 식단 상세 페이지
        case dietDetailPage(id: Int)
        /// 운동 기록 추가 페이지
        case addWorkoutRecordPage
        /// 식단 기록 추가 페이지
        case addDietRecordPage(selectedDate: Date)
        /// 초대코드 입력 페이지
        case traineeInvitationCodeInput
    }
}
