//
//  TrainerManagementView.swift
//  Presentation
//
//  Created by 박서연 on 2/7/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import DesignSystem
import Domain

@ViewAction(for: TrainerManagementFeature.self)
struct TrainerManagementView: View {
    
    public var store: StoreOf<TrainerManagementFeature>
    
    public init(store: StoreOf<TrainerManagementFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Header()
            
            ScrollView(showsIndicators: false) {
                if let trainees = store.traineeList, !trainees.isEmpty {
                    TraineeListView(trainees: trainees)
                        .padding(.vertical, 12)
                } else {
                    EmptyListView()
                        .frame(minHeight: UIScreen.main.bounds.height - 204)
                }
            }
        }
        .onAppear {
            send(.onappear)
        }
        .navigationBarBackButtonHidden()
        .background(Color.neutral100)
    }
    
    @ViewBuilder
    func Header() -> some View {
        HStack(spacing: 6) {
            Text("내 회원")
                .typographyStyle(.heading2, with: .neutral900)
            Text("\(store.traineeList?.count ?? 0)")
                .typographyStyle(.heading2, with: .red500)
            
            Spacer()
            
            Button {
                send(.tapTraineeInvitation)
            } label: {
                Text("회원 초대하기")
                    .typographyStyle(.label2Medium, with: Color.neutral600)
                    .padding(.init(top: 7, leading: 12, bottom: 7, trailing: 12))
                    .background(Color.neutral200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(20)
    }
    
    /// 연결된 회원이 있는 경우
    @ViewBuilder
    func TraineeListView(trainees: [ActiveTraineeInfoResEntity]) -> some View {
        VStack(spacing: 0) {
            ForEach(trainees, id: \.id) { trainee in
                ListCellView(trainee: trainee)
                    .padding(.bottom, 16)
            }
        }
        .padding(.horizontal, 16)
    }
    
    /// 연결된 회원이 없는 경우
    @ViewBuilder
    func EmptyListView() -> some View {
        VStack(spacing: 4) {
            Spacer()
            Text("아직 연결된 회원이 없어요")
                .typographyStyle(.body2Bold, with: Color.neutral600)
            Text("추가 버튼을 눌러 회원을 추가해 보세요")
                .typographyStyle(.label1Medium, with: Color.neutral400)
            Spacer()
        }
    }
    
    @ViewBuilder
    func ListCellView(trainee: ActiveTraineeInfoResEntity) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                HStack(spacing: 12) {
                    ProfileImageView(imageURL: trainee.profileImageUrl)
                    
                    VStack(spacing: 0) {
                        Text(trainee.name)
                            .typographyStyle(.body1Bold, with: Color.neutral900)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(trainee.ptGoals.joined(separator: ", "))
                            .typographyStyle(.label2Medium, with: Color.neutral500)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 9)
                }
                
                Spacer()
                VStack {
                    TChip(leadingEmoji: "💪", title: "\(trainee.finishedPtCount)/\(trainee.totalPtCount)회", style: .blue)
                }
            }
            
            if !trainee.memo.isEmpty {
                VStack(spacing: 5) {
                    Text("메모")
                        .typographyStyle(.label2Bold, with: Color.neutral600)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(trainee.memo)
                        .typographyStyle(.label2Medium, with: Color.neutral500)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension TrainerManagementView {
    struct ProfileImageView: View {
        let imageURL: String?
        
        var body: some View {
            if let urlString = imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .tint(.red500)
                            .frame(width: 60, height: 60)
                        
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                    case .failure:
                        Image(.imgDefaultTrainerImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        
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
}
