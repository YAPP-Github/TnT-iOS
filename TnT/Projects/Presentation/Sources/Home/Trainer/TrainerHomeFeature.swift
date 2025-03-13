//
//  TrainerHomeFeature.swift
//  Presentation
//
//  Created by 박서연 on 2/5/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import Domain
import DesignSystem

@Reducer
public struct TrainerHomeFeature {
    
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
        /// 수업 갯수 정보
        var sessionCount: Int
        /// 수업 정보
        var sessionInfo: WorkoutListItemEntity?
        /// 기록 정보 목록
        var records: [RecordListItemEntity]
        /// 특정 날짜의 수업 정보
        var tappedsessionInfo: GetDateSessionListEntity?
        /// 3일 동안 보지 않기 선택되었는지 여부
        var isHideUntilSelected: Bool
        /// 팝업 관련 Flag
        var popUpFlag: Bool
        
        // MARK: UI related state
        /// 캘린더 표시 페이지
        var view_currentPage: Date
        /// 기록 제목 표시
        var view_recordTitleString: String {
            return TDateFormatUtility.formatter(for: .M월_d일_EEEE).string(from: selectedDate)
        }
        /// 팝업 표시 여부
        var view_isPopUpPresented: Bool
        
        public init(
            selectedDate: Date = .now,
            events: [Date: Int] = [:],
            sessionCount: Int = 0,
            sessionInfo: WorkoutListItemEntity? = nil,
            records: [RecordListItemEntity] = [],
            isHideUntilSelected: Bool = false,
            view_currentPage: Date = .now,
            tappedsessionInfo: GetDateSessionListEntity? = nil,
            view_isPopUpPresented: Bool = false,
            popUpFlag: Bool = false
        ) {
            self.selectedDate = selectedDate
            self.events = events
            self.sessionCount = sessionCount
            self.sessionInfo = sessionInfo
            self.records = records
            self.isHideUntilSelected = isHideUntilSelected
            self.view_currentPage = view_currentPage
            self.tappedsessionInfo = tappedsessionInfo
            self.view_isPopUpPresented = view_isPopUpPresented
            self.popUpFlag = popUpFlag
        }
    }
    
    @Dependency(\.userUseRepoCase) private var userUseRepoCase: UserRepository
    @Dependency(\.traineeUseCase) private var traineeUseCase: TraineeUseCase
    @Dependency(\.trainerRepoUseCase) private var trainerRepoUseCase: TrainerRepository
    
    public enum Action: Sendable, ViewAction {
        /// 뷰에서 발생한 액션을 처리합니다.
        case view(View)
        /// 네비게이션 여부 설정
        case setNavigating(RoutingScreen)
        
        @CasePathable
        public enum View: Sendable, BindableAction {
            /// 바인딩할 액션을 처리
            case binding(BindingAction<State>)
            /// 우측 상단 알림 페이지 보기 버튼 탭
            case tapAlarmPageButton
            /// 수업 완료 버튼 탭
            case tapSessionCompleted(id: String)
            /// 수업 추가 버튼 탭
            case tapAddSessionButton
            /// 연결 권장 팝업 - 다음에 버튼 탭
            case tapPopUpNextButton
            /// 연결 권장 팝업 - 3일 동안 보지 않기 버튼 탭
            case tapPopUpDontShowUntilThreeDaysButton(Bool)
            /// 연결 권장 팝업 - 연결하기 버튼 탭
            case tapPopUpConnectButton
            /// 화면이 표시될 때
            case onAppear
            /// 화면이 표시될 때 - 세션 체크 이후
            case onAppearAfterSessionCheck(isConnected: Bool)
            /// events 타입에 맞춰서 달력 스케줄 캐수 표시 데이터 계산
            case fetchMonthlyLessons(year: Int, month: Int)
            /// 달력 스케줄 캐수 표시 데이터 업데이트
            case updateEvents([Date: Int])
            /// 특정 날짜 탭
            case calendarDateTap
            /// 탭한 일자 api 형태에 맞춰 변환하기(yyyy-mm-dd)
            case settingSessionList(sessions: GetDateSessionListEntity)
            /// 수업 완료 후 토스트 메시지
            case completeToastMessage
            /// 캘린더 데이터 캐싱을 위한 계산
            case isLoadedCheck(currentMonth: Int, nextMonth: Int)
            /// 수업 추가 전 회원 목록 팝업
            case popUpOfCheckTrainee
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
                    return .send(.view(.calendarDateTap))
                    
                case .binding:
                    return .none
                    
                case .tapAlarmPageButton:
                    return .send(.setNavigating(.alarmPage))
                    
                case .tapSessionCompleted(let id):
                    guard let id = Int(id) else { return .none }
                    return .run { send in
                        let _: PutCompleteLessonResDTO = try await trainerRepoUseCase.putCompleteLesson(lessonId: id)
                        await send(.view(.completeToastMessage))
                        await send(.view(.calendarDateTap))
                    }
                    
                case .completeToastMessage:
                    NotificationCenter.default.post(toast: .init(presentType: .image(.icnCheckMarkGreen), message: "PT 수업을 완료했어요"))
                    return .none
                    
                case .tapAddSessionButton:
                    return .run { [state] send in
                        let result: GetActiveTraineesListResDTO = try await trainerRepoUseCase.getActiveTraineesList()
                        
                        if result.trainees.isEmpty {
                            return await send(.view(.popUpOfCheckTrainee))
                        } else {
                            return await send(.setNavigating(.addPTSessionPage(selectedDate: state.selectedDate)))
                        }
                    }
                    
                case .popUpOfCheckTrainee:
                    state.view_isPopUpPresented = true
                    state.popUpFlag = false
                    return .none
                    
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
                    return .send(.setNavigating(.checkTrainerInvitationCode))
                    
                case .onAppear:
                    return .run { send in
                        if let result = try? await userUseRepoCase.getSessionCheck() {
                            await send(.view(.onAppearAfterSessionCheck(isConnected: result.isConnected)))
                        }
                    }
                    
                case .onAppearAfterSessionCheck(let isConnected):
                    state.$isConnected.withLock { $0 = isConnected }
                    let year: Int = Calendar.current.component(.year, from: state.selectedDate)
                    let month: Int = Calendar.current.component(.month, from: state.selectedDate)
                    
                    let hideUntil = state.hidePopupUntil ?? Date()
                    let hidePopUp = state.isConnected || hideUntil > Date()
                    state.view_isPopUpPresented = !hidePopUp
                    state.popUpFlag = !hidePopUp
                    
                    return .concatenate(
                        .send(.view(.fetchMonthlyLessons(year: month == 1 ? year-1 : year, month: month == 1 ? 12 : month-1))),
                        .send(.view(.fetchMonthlyLessons(year: year, month: month))),
                        .send(.view(.fetchMonthlyLessons(year: year, month: month+1))),
                        .send(.view(.calendarDateTap))
                    )
                    
                case .isLoadedCheck(let current, let next):
                    let year: Int = Calendar.current.component(.year, from: state.selectedDate)

                    let isLoaded: Bool = state.events.keys.contains { date in
                        let eventMonth: Int = Calendar.current.component(.month, from: date)
                        return eventMonth == next
                    }
                    
                    if isLoaded {
                        return .none
                    } else {
                        if current > next { /// 이전달로 넘기는 경우
                            return .run { send in
                                await send(.view(.fetchMonthlyLessons(year: current == 1 ? year-1 : year, month: next)))
                            }
                        } else { /// 다음달로 넘기는 경우
                            return .run { send in
                                await send(.view(.fetchMonthlyLessons(year: year, month: next)))
                            }
                        }
                    }
                    
                case .fetchMonthlyLessons(year: let year, month: let month):
                    var events: [Date: Int] = state.events
                    
                    return .run { send in
                        do {
                            let result: GetMonthlyLessonListResDTO = try await trainerRepoUseCase.getMonthlyLessonList(
                                year: year,
                                month: month
                            )
                            
                            for lesson in result.calendarPtLessonCounts {
                                if let date = lesson.date.toDate(format: .yyyyMMdd) {
                                    events[date] = lesson.count
                                } else {
                                    print("Invalid date format: \(lesson.date)")
                                }
                            }
                            await send(.view(.updateEvents(events)))
                        } catch {
                            print("리스트 Fetching Error: \(error)")
                        }
                    }
                    
                case .updateEvents(let events):
                    state.events.merge(events) { current, new in new }
                    return .none
                    
                case .calendarDateTap:
                    let formattedDate: String = TDateFormatUtility.formatter(for: .yyyyMMdd).string(from: state.selectedDate)
                    let events = state.events
                    return .run { send in
                        let sessionList: GetDateSessionListEntity = try await trainerRepoUseCase.getDateSessionList(date: formattedDate).toEntity()
                        await send(.view(.settingSessionList(sessions: sessionList)))
                        await send(.view(.updateEvents(events)))
                    }
                    
                case .settingSessionList(let list):
                    state.tappedsessionInfo = list
                    return .none
                }
            case .setNavigating:
                return .none
            }
        }
    }
}

extension TrainerHomeFeature {
    public enum RoutingScreen: Sendable {
        /// 알림 페이지
        case alarmPage
        /// PT 일정 추가페이지
        case addPTSessionPage(selectedDate: Date)
        /// 초대 코드 발급페이지
        case trainerMakeInvitationCodePage
        /// 초대 코드 확인 페잊
        case checkTrainerInvitationCode
    }
}
