//
//  TrainerMypageView.swift
//  Presentation
//
//  Created by 박서연 on 2/4/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import Domain
import DesignSystem

@ViewAction(for: TrainerMypageFeature.self)
public struct TrainerMypageView: View {
    
    @Bindable public var store: StoreOf<TrainerMypageFeature>
    @Environment(\.scenePhase) private var scenePhase
    
    public init(store: StoreOf<TrainerMypageFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ProfileView()
                StudentInfoView()
                
                VStack(spacing: 12) {
                    TopItemSection()
                    InfoItemSection()
                    BottomItemSection()
                }
                .padding(20)
            }
        }
        .onAppear { send(.onAppear) }
        .onChange(of: scenePhase) { send(.onAppear) }
        .background(Color.neutral50)
        .navigationBarBackButtonHidden()
        .tPopUp(isPresented: $store.view_isPopUpPresented) {
            PopUpView()
        }
    }
    
    @ViewBuilder
    private func PopUpView() -> some View {
        if let popUp = store.view_popUp {
            let buttons: [TPopupAlertState.ButtonState] = [
                popUp.secondaryAction.map({ action in
                    TPopupAlertState.ButtonState(title: "취소", style: .secondary, action: .init(action: { send(action) }))
                }),
                TPopupAlertState.ButtonState(title: "확인", style: .primary, action: .init(action: { send(popUp.primaryAction) }))
            ].compactMap { $0 }
            
            TPopUpAlertView(
                alertState: TPopupAlertState(
                    title: popUp.title,
                    message: popUp.message,
                    showAlertIcon: popUp.alertIcon,
                    buttons: buttons
                )
            )
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func ProfileView() -> some View {
        VStack(spacing: 0) {
            ProfileImageView(imageURL: store.userImageUrl)
                .padding(.vertical, 12)
            Text(store.userName)
                .typographyStyle(.heading2, with: .neutral950)
        }
    }
    
    @ViewBuilder
    private func StudentInfoView() -> some View {
        HStack(spacing: 9) {
            StudentInfoItem(title: "관리 중인 회원", count: store.studentCount)
            StudentInfoItem(title: "함께했던 회원", count: store.oldStudentCount)
        }
        .padding(.horizontal, 40)
    }
    
    @ViewBuilder
    private func TopItemSection() -> some View {
        VStack(spacing: 12) {
            ProfileItemView(title: "앱 푸시 알림", rightView: {
                Toggle("appPushNotification", isOn: $store.appPushNotificationAllowed)
                    .applyTToggleStyle()
            })
            .padding(.vertical, 4)
            .background(Color.common0)
            .clipShape(.rect(cornerRadius: 12))
        }
    }
    
    @ViewBuilder
    private func InfoItemSection() -> some View {
        VStack(spacing: 12) {
            ProfileItemView(title: "서비스 이용약관", tapAction: { send(.tapTOSButton) })
            ProfileItemView(title: "개인정보 처리방침", tapAction: { send(.tapPrivacyPolicyButton) })
            ProfileItemView(title: "버전 정보", rightView: {
                Text("0.0.1")
                    .typographyStyle(.body2Medium, with: .neutral400)
            })
            ProfileItemView(title: "오픈소스 라이선스", tapAction: { send(.tapOpenSourceLicenseButton) })
        }
        .padding(.vertical, 12)
        .background(Color.common0)
        .clipShape(.rect(cornerRadius: 12))
    }
    
    @ViewBuilder
    private func BottomItemSection() -> some View {
        VStack(spacing: 12) {
            ProfileItemView(title: "로그아웃", tapAction: { send(.tapLogoutButton) })
            ProfileItemView(title: "계정 탈퇴", tapAction: { send(.tapWithdrawButton) })
        }
        .padding(.vertical, 12)
        .background(Color.common0)
        .clipShape(.rect(cornerRadius: 12))
    }
}

extension TrainerMypageView {
    struct StudentInfoItem: View {
        let title: String
        let count: Int
        
        var body: some View {
            VStack {
                Text(title)
                    .typographyStyle(.label1Bold, with: .neutral500)
                HStack(spacing: 0) {
                    Image(.icnBomb)
                        .resizable()
                        .frame(width: 28, height: 28)
                    Text("\(count)")
                        .typographyStyle(.body1Medium, with: .neutral950)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.neutral100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
        }
    }
    
    struct ProfileImageView: View {
        let imageURL: String?
        
        var body: some View {
            if let urlString = imageURL, let url = URL(string: urlString) {
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
    
    struct ProfileItemView<RightView: View>: View {
        let title: String
        let rightView: () -> RightView
        let tapAction: (() -> Void)?
        
        init(
            title: String,
            rightView: @escaping () -> RightView = { EmptyView() },
            tapAction: (() -> Void)? = nil
        ) {
            self.title = title
            self.rightView = rightView
            self.tapAction = tapAction
        }
        
        var body: some View {
            HStack {
                Text(title)
                    .typographyStyle(.body2Medium, with: .neutral700)
                Spacer()
                rightView()
            }
            .onTapGesture {
                tapAction?()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
}
