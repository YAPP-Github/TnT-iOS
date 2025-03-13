//
//  TraineeAddDietRecordView.swift
//  Presentation
//
//  Created by 박민서 on 2/10/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI

import Domain
import DesignSystem

/// 식단 기록을 추가하는 화면
@ViewAction(for: TraineeAddDietRecordFeature.self)
public struct TraineeAddDietRecordView: View {
    
    @Bindable public var store: StoreOf<TraineeAddDietRecordFeature>
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) var dismiss: DismissAction
    
    /// `TraineeAddDietRecordView` 생성자
    /// - Parameter store: `TraineeAddDietRecordFeature`와 연결된 Store
    public init(store: StoreOf<TraineeAddDietRecordFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            TNavigation(
                type: .LButtonWithTitle(
                    leftImage: .icnArrowLeft,
                    centerTitle: "식단 기록"
                ),
                leftAction: { send(.tapNavBackButton) }
            )
            TDivider(color: .neutral200)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    DietPhotoSection()
                    
                    VStack(spacing: 48) {
                        DietDateSection()
                        DietTimeSection()
                        DietTypeSection()
                        DietInfoSection()
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.bottom, .safeAreaBottom + 20)
            }
            .keyboardDismissOnTap()
        }
        .onTapGesture { focusedField = nil }
        .navigationBarBackButtonHidden()
        .keyboardDismissOnTap()
        .bottomFixWith {
            TButton(
                title: "저장",
                config: .xLarge,
                state: .default(.primary(isEnabled: store.view_isSubmitButtonEnabled))
            ) {
                send(.tapSubmitButton)
            }
            .padding(.bottom, .safeAreaBottom)
            .disabled(!store.view_isSubmitButtonEnabled)
            .debounce()
            .padding(.horizontal, 16)
            .background(Color.common0)
        }
        .sheet(item: $store.view_bottomSheetItem) { item in
            switch item {
            case .datePicker(let field):
                TDatePickerView(
                    selectedDate: store.dietDate ?? .now,
                    title: field.title,
                    monthFormatter: { TDateFormatUtility.formatter(for: .yyyy년_MM월).string(from: $0) },
                    buttonAction: {
                        send(.tapBottomSheetSubmitButton(.dietDate, $0))
                    }
                )
                .autoSizingBottomSheet(presentationDragIndicator: .hidden)
            case .timePicker(let field):
                TTimePickerView(
                    selectedTime: store.dietTime ?? .now,
                    title: field.title,
                    minuteStep: 1,
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
    private func DietPhotoSection() -> some View {
        PhotoPickerView(store: store.scope(
            state: \.photoLibraryState,
            action: \.subFeature.photoLibrary
        ), selectedItem: $store.view_photoPickerItem) {
            GeometryReader { geometry in
                if let imageData = store.dietImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipShape(.rect(cornerRadius: 20))
                        .overlay(alignment: .topTrailing) {
                            Button(action: { send(.tapPhotoPickerDeleteButton)}) {
                                ZStack {
                                    Circle()
                                        .fill(Color.common100.opacity(0.5))
                                        .frame(width: 24, height: 24)
                                    Image(.icnDelete)
                                        .renderingMode(.template)
                                        .resizable()
                                        .tint(.common0)
                                        .frame(width: 12, height: 12)
                                }
                                .padding(8)
                            }
                        }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: geometry.size.width, height: geometry.size.width)
                        
                        VStack(spacing: 8) {
                            Image(.icnImage)
                                .resizable()
                                .frame(width: 48, height: 48)
                            
                            Text("오늘 먹은 식단을 추가해보세요")
                                .typographyStyle(.body2Medium, with: .neutral400)
                        }
                    }
                }
            }
            .tint(Color.neutral100)
            .aspectRatio(1.0, contentMode: .fit)
        }
        .padding(20)
    }
    
    @ViewBuilder
    private func DietDateSection() -> some View {
        TTextField(
            placeholder: Date().toString(format: .yyyyMMddSlash),
            text: Binding(get: {
                store.dietDate?.toString(format: .yyyyMMddSlash) ?? ""
            }, set: { _ in }),
            textFieldStatus: $store.view_dietDateStatus
        )
        .withSectionLayout(header: .init(isRequired: true, title: "식사 날짜", limitCount: nil, textCount: nil))
        .focused($focusedField, equals: .dietDate)
        .allowsHitTesting(false)
        .overlay(
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { send(.tapDietDateDropDown) }
        )
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func DietTimeSection() -> some View {
        TTextField(
            placeholder: Date().toString(format: .HHmm),
            text: Binding(get: {
                store.dietTime?.toString(format: .HHmm) ?? ""
            }, set: { _ in }),
            textFieldStatus: $store.view_dietTimeStatus
        )
        .withSectionLayout(header: .init(isRequired: true, title: "식사 시간", limitCount: nil, textCount: nil))
        .focused($focusedField, equals: .dietTime)
        .allowsHitTesting(false)
        .overlay(
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { send(.tapDietTimeDropDown) }
        )
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func DietTypeSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            TTextField.Header(isRequired: true, title: "분류", limitCount: nil, textCount: nil)
            
            HStack(spacing: 8) {
                ForEach(DietType.allCases, id: \.koreanName) { item in
                    Button(action: {
                        send(.tapDietTypeButton(item))
                    }) {
                        Text(item.koreanName)
                            .typographyStyle(
                                .body1Medium,
                                with: store.dietType == item ? .red600 : .neutral500
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(store.dietType == item ? Color.red50 : Color.common0)
                                    .stroke(
                                        store.dietType == item ? Color.red400 : Color.neutral300,
                                        lineWidth: 1.5
                                    )
                            }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func DietInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TTextField.Header(isRequired: true, title: "메모하기", limitCount: nil, textCount: nil)
            
            TTextEditor(
                placeholder: "식단에 대한 정보를 입력해주세요!",
                text: $store.dietInfo,
                textEditorStatus: $store.view_dietInfoStatus,
                footer: {
                    .init(
                        textLimit: 100,
                        status: $store.view_dietInfoStatus,
                        textCount: store.dietInfo.count,
                        warningText: "100자 미만으로 입력해주세요"
                    )
                }
            )
            .focused($focusedField, equals: .dietInfo)
        }
    }
    
    @ViewBuilder
    private func PopUpView() -> some View {
        if let popUp = store.view_popUp {
            let buttons: [TPopupAlertState.ButtonState] = [
                popUp.secondaryAction.map { action in
                        .init(title: "취소", style: .secondary, action: .init(action: { send(action) }))
                },
                .init(title: "확인", style: .primary, action: .init(action: { send(popUp.primaryAction) }))
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

public extension TraineeAddDietRecordView {
    enum Field: Sendable, Hashable {
        case dietDate
        case dietTime
        case dietInfo
        
        var title: String {
            switch self {
            case .dietDate:
                return "식단 날짜 선택하기"
            case .dietTime:
                return "식단 시간 선택하기"
            case .dietInfo:
                return "식단 정보"
            }
        }
    }
}
