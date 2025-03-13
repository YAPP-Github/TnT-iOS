//
//  TrainerAddPTSessionView.swift
//  Presentation
//
//  Created by 박민서 on 2/6/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import Domain
import DesignSystem

/// PT 수업을 추가하는 화면
@ViewAction(for: TrainerAddPTSessionFeature.self)
public struct TrainerAddPTSessionView: View {
    
    @Bindable public var store: StoreOf<TrainerAddPTSessionFeature>
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) var dismiss: DismissAction
    
    /// `TraineeBasicInfoInputView` 생성자
    /// - Parameter store: `TraineeBasicInfoInputFeature`와 연결된 Store
    public init(store: StoreOf<TrainerAddPTSessionFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            TNavigation(
                type: .LButtonWithTitle(
                    leftImage: .icnArrowLeft,
                    centerTitle: "수업 추가하기"
                ),
                leftAction: { send(.tapNavBackButton) }
            )
            TDivider(height: 1, color: .neutral200)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Header()
                        .padding(.bottom, 28)
                    
                    VStack(spacing: 48) {
                        TraineeDropDown()
                        
                        PtDateDropDown()
                        
                        VStack(spacing: 20) {
                            TimeDropDown()
                            TimeResult()
                        }
                        
                        TimeChip()
                        
                        Memo()
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.bottom, .safeAreaBottom + 20)
            }
        }
        .bottomFixWith {
            TBottomButton(
                title: "완료",
                isEnable: store.view_isSubmitButtonEnabled
            ) {
                send(.tapSubmitButton)
            }
            .padding(.bottom, .safeAreaBottom)
            .disabled(!store.view_isSubmitButtonEnabled)
            .debounce()
        }
        .onTapGesture { focusedField = nil }
        .navigationBarBackButtonHidden()
        .keyboardDismissOnTap()
        .sheet(item: $store.view_bottomSheetItem) { item in
            switch item {
            case .traineeList:
                TrainerSelectSessionTraineeView(
                    traineeList: store.traineeList.map { item in
                        (listItem: item, action: { send(.tapTraineeAtBottomSheet(item)) })
                    },
                    selectedTraineeId: store.trainee?.id
                )
            case .datePicker(let field):
                TDatePickerView(
                    selectedDate: store.ptDate ?? .now,
                    title: field.title,
                    monthFormatter: { TDateFormatUtility.formatter(for: .yyyy년_MM월).string(from: $0) },
                    buttonAction: {
                        send(.tapBottomSheetSubmitButton(.ptDate, $0))
                    }
                )
                .autoSizingBottomSheet(presentationDragIndicator: .hidden)
            case .timePicker(let field):
                TTimePickerView(
                    selectedTime: (field == .startTime ? store.startTime : store.endTime) ?? .now,
                    title: field.title,
                    minuteStep: 10,
                    buttonAction: {
                        send(.tapBottomSheetSubmitButton(field, $0))
                    }
                )
                .autoSizingBottomSheet(presentationDragIndicator: .hidden)
            }
        }
        .tPopUp(isPresented: $store.view_isPopUpPresented) {
            PopUpView()
        }
        .onChange(of: store.view_bottomSheetItem) { oldValue, newValue in
            if oldValue != newValue {
                send(.setFocus(oldValue?.field, newValue?.field))
            }
        }
        .onChange(of: focusedField) { oldValue, newValue in
            if oldValue != newValue {
                send(.setFocus(oldValue, newValue))
            }
        }
        .onAppear { send(.onAppear) }
    }
    
    // MARK: - Sections
    @ViewBuilder
    private func Header() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("언제 수업할까요?")
                .typographyStyle(.heading2, with: .neutral950)
            Text("일정을 등록하면 회원에게도 일정이 등록돼요")
                .typographyStyle(.body2Medium, with: .neutral500)
        }
        .padding(20)
    }
    
    @ViewBuilder
    private func TraineeDropDown() -> some View {
        TTextField(
            placeholder: "회원을 입력해주세요",
            text: Binding(get: {
                store.trainee?.name ?? ""
            }, set: { _ in }),
            textFieldStatus: $store.view_traineeStatus
        ) {
            TTextField.RightView(
                style: .dropDown(
                    tintColor: focusedField == .ptDate ? Color.neutral600 : Color.neutral400,
                    tapAction: { }
                )
            )
        }
        .withSectionLayout(header: .init(isRequired: true, title: "회원선택", limitCount: nil, textCount: nil))
        .focused($focusedField, equals: .ptDate)
        .allowsHitTesting(false)
        .overlay(
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { send(.tapTraineeDropDown) }
        )
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func PtDateDropDown() -> some View {
        TTextField(
            placeholder: "날짜를 입력해주세요",
            text: Binding(get: {
                store.ptDate?.toString(format: .yyyyMMddSlash) ?? ""
            }, set: { _ in }),
            textFieldStatus: $store.view_ptDateStatus
        ) {
            TTextField.RightView(
                style: .dropDown(
                    tintColor: focusedField == .ptDate ? Color.neutral600 : Color.neutral400,
                    tapAction: { }
                )
            )
        }
        .withSectionLayout(header: .init(isRequired: true, title: "PT 날짜", limitCount: nil, textCount: nil))
        .focused($focusedField, equals: .trainee)
        .allowsHitTesting(false)
        .overlay(
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { send(.tapPtDateDropDown) }
        )
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func TimeDropDown() -> some View {
        HStack(alignment: .bottom, spacing: 12) {
            // StartTime
            TTextField(
                placeholder: Date().toString(format: .HHmm),
                text: Binding(get: {
                    store.startTime?.toString(format: .HHmm) ?? ""
                }, set: { _ in }),
                textFieldStatus: $store.view_startTimeStatus
            ) {
                TTextField.RightView(
                    style: .dropDown(
                        tintColor: focusedField == .ptDate ? Color.neutral600 : Color.neutral400,
                        tapAction: { }
                    )
                )
            }
            .withSectionLayout(header: .init(isRequired: true, title: "시작 시간", limitCount: nil, textCount: nil))
            .focused($focusedField, equals: .trainee)
            .allowsHitTesting(false)
            .overlay(
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { send(.tapStartTimeDropDown) }
            )
            .frame(maxWidth: .infinity)
            
            Text("~")
                .typographyStyle(.body1Medium, with: .neutral600)
                .padding(8)
            
            // EndTime
            TTextField(
                placeholder: Date().addingTimeInterval(3600).toString(format: .HHmm),
                text: Binding(get: {
                    store.endTime?.toString(format: .HHmm) ?? ""
                }, set: { _ in }),
                textFieldStatus: $store.view_endTimeStatus
            ) {
                TTextField.RightView(
                    style: .dropDown(
                        tintColor: focusedField == .ptDate ? Color.neutral600 : Color.neutral400,
                        tapAction: { }
                    )
                )
            }
            .withSectionLayout(header: .init(isRequired: true, title: "종료 시간", limitCount: nil, textCount: nil))
            .focused($focusedField, equals: .endTime)
            .allowsHitTesting(false)
            .overlay(
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { send(.tapEndTimeDropDown) }
            )
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private func TimeChip() -> some View {
        if store.startTime != nil && store.endTime == nil {
            VStack(alignment: .leading, spacing: 16) {
                Text("수업 시간")
                    .typographyStyle(.body1Bold, with: .neutral900)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(TrainerAddPTSessionFeature.SessionTime.allCases, id: \.rawValue) { interval in
                        TButton(
                            title: "+\(interval.rawValue)분",
                            config: .medium,
                            state: store.view_sessionTime == interval.rawValue
                            ? .default(.red(isEnabled: true))
                            : .default(.outline(isEnabled: true)),
                            action: { send(.tapSessionIntervalButton(interval)) }
                        )
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func TimeResult() -> some View {
        if store.startTime != nil && store.endTime != nil {
            HStack(spacing: 8) {
                Image(.icnClockRed)
                    .resizable()
                    .frame(width: 16, height: 16)
                HStack(spacing: 0) {
                    Text("총")
                        .typographyStyle(.body2Medium, with: .neutral700)
                    Text(" \(store.view_sessionTime ?? 0)분 ")
                        .typographyStyle(.body2Bold, with: .neutral700)
                    Text("수업이에요")
                        .typographyStyle(.body2Medium, with: .neutral700)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.neutral100)
            )
        }
    }
    
    @ViewBuilder
    private func Memo() -> some View {
        VStack(spacing: 8) {
            TTextField.Header(isRequired: false, title: "메모하기", limitCount: nil, textCount: nil)
            TTextEditor(
                placeholder: "PT 수업에서 기억해야 할 것을 메모해보세요",
                text: $store.memo,
                textEditorStatus: $store.view_memoStatus,
                footer: {
                    .init(
                        textLimit: 30,
                        status: $store.view_memoStatus,
                        textCount: store.memo.count,
                        warningText: "30자 미만으로 입력해주세요"
                    )
                }
            )
            .focused($focusedField, equals: .memo)
        }
    }
    
    @ViewBuilder
    private func PopUpView() -> some View {
        if let popUp = store.view_popUp {
            let buttons: [TPopupAlertState.ButtonState] = [
                popUp.secondaryAction.map { action in
                    .init(title: "취소", style: .secondary, action: .init(action: { send(action) }))
                },
                .init(title: popUp.primaryTitle, style: .primary, action: .init(action: { send(popUp.primaryAction) }))
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

public extension TrainerAddPTSessionView {
    enum Field: Sendable, Hashable {
        case trainee
        case ptDate
        case startTime
        case endTime
        case memo
        
        var title: String {
            switch self {
                
            case .trainee:
                return "회원 선택하기"
            case .ptDate:
                return "PT날짜 선택하기"
            case .startTime:
                return "시작 시간 선택하기"
            case .endTime:
                return "종료 시간 선택하기"
            case .memo:
                return "메모하기"
            }
        }
    }
}
