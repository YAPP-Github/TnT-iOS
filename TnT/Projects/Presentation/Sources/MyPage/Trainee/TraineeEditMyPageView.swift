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
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }
            }
            .scrollDismissesKeyboard(.interactively)
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
                send(.tapNavBackButton)
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
            text: $store.userName,
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
