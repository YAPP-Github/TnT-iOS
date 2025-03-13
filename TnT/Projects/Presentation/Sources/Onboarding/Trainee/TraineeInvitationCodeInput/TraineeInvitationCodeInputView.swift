//
//  TraineeInvitationCodeInputView.swift
//  Presentation
//
//  Created by 박민서 on 1/26/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import Domain
import DesignSystem

/// 트레이너 초대 코드를 입력하는 화면
@ViewAction(for: TraineeInvitationCodeInputFeature.self)
public struct TraineeInvitationCodeInputView: View {
    
    @Bindable public var store: StoreOf<TraineeInvitationCodeInputFeature>
    @FocusState private var focusedField: Bool
    
    /// `TraineeInvitationCodeInputView` 생성자
    /// - Parameter store: `TraineeInvitationCodeInputFeature`와 연결된 Store
    public init(store: StoreOf<TraineeInvitationCodeInputFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            NavigationBar()
            .padding(.bottom, 24)
            
            Header()
                .padding(.bottom, 48)
            
            TextFieldSection()
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .navigationPopGestureDisabled(store.view_navigationType == .newUser)
        .keyboardDismissOnTap()
        .bottomFixWith {
            TBottomButton(
                title: "다음",
                isEnable: store.view_isNextButtonEnabled
            ) {
                send(.tapNextButton)
            }
            .padding(.bottom, .safeAreaBottom)
            .disabled(!store.view_isNextButtonEnabled)
        }
        .onChange(of: focusedField) { oldValue, newValue in
            if oldValue != newValue {
                send(.setFocus(newValue))
            }
        }
        .onChange(of: store.view_isFieldFocused) { oldValue, newValue in
            if oldValue != newValue {
                focusedField = newValue
            }
        }
        .tPopUp(isPresented: $store.view_isPopupPresented) {
            PopUpView()
        }
    }
    
    // MARK: - Sections
    @ViewBuilder
    private func NavigationBar() -> some View {
        switch store.view_navigationType {
        case .newUser:
            TNavigation(
                type: .RTextWithTitle(
                    centerTitle: "연결하기",
                    rightText: "건너뛰기"
                ),
                rightAction: {
                    send(.tapNavBarSkipButton)
                }
            )
        case .existingUser:
            TNavigation(
                type: .LButtonWithTitle(
                    leftImage: .icnArrowLeft,
                    centerTitle: "연결하기"
                ),
                leftAction: {
                    send(.tapNavBarBackButton)
                }
            )
        }
    }
    
    @ViewBuilder
    private func Header() -> some View {
        TInfoTitleHeader(title: "트레이너에게 받은\n초대 코드를 입력해 주세요")
    }
    
    @ViewBuilder
    private func TextFieldSection() -> some View {
        VStack(spacing: 48) {
            TTextField(
                placeholder: "코드를 입력해주세요",
                text: Binding(get: {
                    store.invitationCode
                }, set: {
                    if store.invitationCode != $0 {
                        store.invitationCode = $0
                    }
                }),
                textFieldStatus: $store.view_invitationCodeStatus,
                rightView: {
                    TTextField.RightView(
                        style: .button(
                            title: "인증하기",
                            state: store.view_isVerityButtonEnabled
                            ? .default(.primary(isEnabled: true))
                            : .disable(.primary(isEnabled: false)),
                            tapAction: {
                                send(.tapVerifyButton)
                            }
                        )
                    )
                }
            )
            .withSectionLayout(
                header: .init(isRequired: true, title: "내 초대 코드", limitCount: nil, textCount: nil),
                footer: .init(footerText: store.view_textFieldFooterText, status: store.view_invitationCodeStatus)
            )
            .focused($focusedField)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private func PopUpView() -> some View {
        if let popUp = store.view_popUp {
            let buttons: [TPopupAlertState.ButtonState] = [
                .init(
                    title: popUp.secondaryButtonTitle,
                    style: .secondary,
                    action: .init(action: { send(popUp.secondaryAction) })
                ),
                .init(
                    title: popUp.primaryButtonTitle,
                    style: .primary,
                    action: .init(action: { send(popUp.primaryAction) })
                )
            ]
            
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
