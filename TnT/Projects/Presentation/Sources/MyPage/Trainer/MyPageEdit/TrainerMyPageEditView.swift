//
//  TrainerMyPageEditView.swift
//  Presentation
//
//  Created by 박민서 on 7/6/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

import Domain
import DesignSystem

/// 트레이너 마이페이지 내 정보 수정을 담당하는 View입니다.
@ViewAction(for: TrainerMyPageEditFeature.self)
public struct TrainerMyPageEditView: View {
    
    @Bindable public var store: StoreOf<TrainerMyPageEditFeature>
    @Environment(\.dismiss) var dismiss: DismissAction
    
    public init(store: StoreOf<TrainerMyPageEditFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            TNavigation(
                type: .LButtonWithTitle(leftImage: .icnArrowLeft, centerTitle: "내 정보 수정"),
                leftAction: {
                    send(.tapNavBackButton)
                }
            )
            
            VStack(spacing: 24) {
                
                ImageSection()
                
                TextFieldSection()
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .keyboardDismissOnTap()
        .bottomFixWith {
            TBottomButton(
                title: "완료",
                isEnable: store.view_isDoneButtonEnabled
            ) {
                send(.tapDoneButton)
            }
            .padding(.bottom, .safeAreaBottom)
            .disabled(!store.view_isDoneButtonEnabled)
            .debounce()
        }
        .tPopUp(isPresented: $store.view_isPopUpPresented) {
            PopUpView()
        }
    }
    
    @ViewBuilder
    private func ImageSection() -> some View {
        Group {
            if let imageData = store.userImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } else {
                Image(.imgDefaultTrainerImage)
                .resizable()
                .clipShape(Circle())
            }
        }
        .frame(width: 132, height: 132)
        .overlay(alignment: .bottomTrailing) {
            PhotoPickerView(store: store.scope(
                state: \.photoLibraryState,
                action: \.subFeature.photoLibrary
            ), selectedItem: $store.view_photoPickerItem) {
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
    
    @ViewBuilder
    private func TextFieldSection() -> some View {
        TTextField(
            placeholder: "닉네임을 입력해주세요",
            text: $store.userName,
            textFieldStatus: $store.view_textFieldStatus
        )
        .withSectionLayout(
            header: .init(
                isRequired: true,
                title: "닉네임",
                limitCount: 15,
                textCount: store.userName.count
            ),
            footer: .init(
                footerText: store.view_isFooterTextVisible
                ? "15자 미만의 한글 또는 영문으로 입력해주세요"
                : "",
                status: store.view_textFieldStatus
            )
        )
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func PopUpView() -> some View {
        if let popUp = store.view_popUp {
            let buttons: [TPopupAlertState.ButtonState] = [
                .init(title: popUp.secondaryTitle, style: .secondary, action: .init(action: { send(popUp.secondaryAction) })),
                .init(title: popUp.primaryTitle, style: .primary, action: .init(action: { send(popUp.primaryAction) }))
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
