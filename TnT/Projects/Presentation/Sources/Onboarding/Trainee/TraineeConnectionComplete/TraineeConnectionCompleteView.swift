//
//  TraineeConnectionCompleteView.swift
//  Presentation
//
//  Created by 박민서 on 1/28/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import Domain
import DesignSystem

/// 트레이너-트레이니 연결을 표시하는 화면
@ViewAction(for: TraineeConnectionCompleteFeature.self)
public struct TraineeConnectionCompleteView: View {
    
    public let store: StoreOf<TraineeConnectionCompleteFeature>
    
    public init(store: StoreOf<TraineeConnectionCompleteFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            Background()
            
            // Main
            VStack(spacing: 0) {
                Color.clear
                    .frame(heightRatio: 0.1)
                
                Header()
                    
                Spacer()
                
                Image(.imgBoom)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(heightRatio: 0.38)
                    .padding(horizontalRatio: 0.05)
                
                Spacer()
                
                TBottomButton(title: "다음", isEnable: true) {
                    send(.tapNextButton)
                }
                .padding(.bottom, .safeAreaBottom)
                .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationPopGestureDisabled()
        .onAppear { send(.onAppear) }
    }
    
    // MARK: - Sections
    @ViewBuilder
    private func Background() -> some View {
        Image(.imgConnectionCompleteBackground)
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .clipped()
            .ignoresSafeArea()
    }
    @ViewBuilder
    private func Header() -> some View {
        VStack(spacing: 40) {
            Text("\(store.view_opponentUserName)  \(store.view_opponentUserType.koreanName)와\n연결되었어요!")
                .typographyStyle(.heading1, with: .common0)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Spacer()
                UserProfileView(
                    imageURL: store.view_opponentUserImageURL,
                    userType: store.view_opponentUserType,
                    name: store.view_opponentUserName
                )
                UserProfileView(
                    imageURL: store.view_myImageURL,
                    userType: store.userType,
                    name: store.view_myName
                )
                Spacer()
            }
        }
    }
}

private extension TraineeConnectionCompleteView {
    /// 사용자의 프로필 이미지와 이름을 표시하는 뷰
    struct UserProfileView: View {
        let imageURL: String?
        let userType: UserType
        let name: String
        
        var defaultImage: ImageResource {
            self.userType == .trainee ? .imgDefaultTraineeImage : .imgDefaultTrainerImage
        }
        
        var body: some View {
            VStack(spacing: 12) {
                if let urlString = imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(.red500)
                                .frame(width: 100, height: 100)
                            
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            
                        case .failure:
                            Image(defaultImage)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .scaledToFill()
                                .clipShape(Circle())
                            
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(defaultImage)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .scaledToFill()
                        .clipShape(Circle())
                }
                
                Text(name)
                    .typographyStyle(.body2Medium, with: .neutral300)
                    .frame(maxWidth: .infinity)
            }
            .frame(width: 100)
        }
    }
}
