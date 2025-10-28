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
import UIKit

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
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    ImageSection()
                    
                    TextFieldSection()
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
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
        .sheet(isPresented: $store.view_isBottomSheetPresented) {
            VStack(spacing: 4) {
                EditBottomSheetButton(title: "삭제하기") { send(.tapBottomSheetDeleteButton) }

                EditBottomSheetButton(title: "앨범에서 사진 선택") { send(.tapBottomSheetSelectButton) }
            }
            .padding(.bottom, 20)
            .autoSizingBottomSheet()
        }
        .tPopUp(isPresented: $store.view_isPopUpPresented) {
            PopUpView()
        }
    }
    
    @ViewBuilder
    private func ImageSection() -> some View {
        let imageURL = store.currentUserInfo.removeImage ? nil : store.currentUserInfo.prevProfileImageURL
        ProfileImageView(imageURL: imageURL, imageData: store.userImageData)
            .frame(width: 132, height: 132)
            .overlay(alignment: .bottomTrailing) {
                Button(action: {
                    send(.tapWriteButton)
                }, label: {
                    ZStack {
                        Circle()
                            .fill(Color.neutral900)

                        Image(.icnWriteWhite)
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    .frame(width: 28, height: 28)
                })
            }
    }
    
    @ViewBuilder
    private func TextFieldSection() -> some View {
        let limit = store.view_nameMaxLength ?? 15

        TTextField(
            placeholder: "닉네임을 입력해주세요",
            text: $store.userName,
            textFieldStatus: $store.view_textFieldStatus
        )
        .withSectionLayout(
            header: .init(
                isRequired: true,
                title: "닉네임",
                limitCount: limit,
                textCount: store.userName.count
            ),
            footer: .init(
                footerText: store.view_isFooterTextVisible
                ? "\(limit)자 미만의 한글 또는 영문으로 입력해주세요"
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

    struct ProfileImageView: View {
        let imageURL: String?
        let imageData: Data?

        var body: some View {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 132, height: 132)
                    .clipShape(Circle())
            } else if let urlString = imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .tint(.red500)
                            .frame(width: 132, height: 132)

                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 132, height: 132)
                            .clipShape(Circle())

                    case .failure:
                        Image(.imgDefaultTrainerImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 132, height: 132)
                            .clipShape(Circle())

                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(.imgDefaultTrainerImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 132, height: 132)
                    .clipShape(Circle())
            }
        }
    }

    struct EditBottomSheetButton: View {
        let title: String
        let action: () -> Void

        var body: some View {
            Button(action: action, label: {
                HStack {
                    Text(title)
                        .typographyStyle(.body1Semibold, with: .neutral600)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 2.5)
            })
            .frame(height: 40)
        }
    }
}



// PhotoPickerPresenter.swift

import UIKit
import PhotosUI
import UniformTypeIdentifiers

@MainActor
final class PhotoPickerPresenter: NSObject, PHPickerViewControllerDelegate {
    static let shared = PhotoPickerPresenter()
    private var continuation: CheckedContinuation<Data?, Never>?

    /// 1장 선택, 편집 버전(current) 선호
    func present(selectionLimit: Int = 1) async -> Data? {
        // 이미 진행 중이면 이전 요청 무시
        if continuation != nil { return nil }

        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = selectionLimit
        config.filter = .images
        config.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self

        guard let top = Self.topMostViewController() else { return nil }
        top.present(picker, animated: true)

        return await withCheckedContinuation { (cont: CheckedContinuation<Data?, Never>) in
            self.continuation = cont
        }
    }

    // MARK: - PHPicker Delegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let cont = continuation else { return }
        continuation = nil

        guard let first = results.first else {
            cont.resume(returning: nil)
            return
        }

        // UIImage로 로드 → JPEG로 인코딩 (HEIC 등 호환 위해)
        if first.itemProvider.canLoadObject(ofClass: UIImage.self) {
            first.itemProvider.loadObject(ofClass: UIImage.self) { obj, _ in
                let img = obj as? UIImage
                let data = img?.jpegData(compressionQuality: 0.9)
                DispatchQueue.main.async { cont.resume(returning: data) }
            }
            return
        }

        // 혹은 원시 데이터 시도
        if first.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            first.itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                DispatchQueue.main.async { cont.resume(returning: data) }
            }
            return
        }

        cont.resume(returning: nil)
    }

    // MARK: - Top VC
    private static func topMostViewController(base: UIViewController? = {
        // 여러 씬 중 포어그라운드 활성 씬의 키 윈도우
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }

        let keyWin = scenes.first?.windows.first(where: { $0.isKeyWindow })
        return keyWin?.rootViewController
    }()) -> UIViewController? {

        return UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .windows
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
