//
//  ConnectionCompleteView.swift
//  Presentation
//
//  Created by 박서연 on 1/24/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import DesignSystem
import Domain

@ViewAction(for: ConnectionCompleteFeature.self)
public struct ConnectionCompleteView: View {
    
    public let store: StoreOf<ConnectionCompleteFeature>
    
    public init(store: StoreOf<ConnectionCompleteFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            Image(.imgConnectionCompleteBackground)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Color.clear
                    .frame(heightRatio: 0.1)
                
                Header()
                    
                Spacer()
                
                Image(.imgBoom)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(heightRatio: 0.35)
                    .padding(horizontalRatio: 0.05)
                
                Spacer()
                
                TBottomButton(title: "다음", isEnable: true) {
                    send(.tappedNextButton)
                }
                .padding(.bottom, .safeAreaBottom)
                .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        .onAppear { send(.onAppear) }
        .navigationBarBackButtonHidden()
        .navigationPopGestureDisabled()
    }
    
    @ViewBuilder
    private func Header() -> some View {
        VStack(spacing: 40) {
            Text("\(store.traineeProfile?.traineeName ?? "") 트레이니와\n연결되었어요!")
                .typographyStyle(.heading1, with: .common0)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Spacer()
                UserProfileView(
                    imageURL: store.connectionInfo?.traineeProfileImageUrl,
                    userType: .trainee,
                    name: store.connectionInfo?.traineeName ?? ""
                )
                UserProfileView(
                    imageURL: store.connectionInfo?.trainerProfileImageUrl,
                    userType: .trainer,
                    name: store.connectionInfo?.trainerName ?? ""
                )
                Spacer()
            }
        }
    }
}

private extension ConnectionCompleteView {
    struct UserProfileView: View {
        let imageURL: URL?
        let userType: UserType
        let name: String
        
        var defaultImage: ImageResource {
            self.userType == .trainee ? .imgDefaultTraineeImage : .imgDefaultTrainerImage
        }
        
        var body: some View {
            VStack(spacing: 12) {
                if let url = imageURL {
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
