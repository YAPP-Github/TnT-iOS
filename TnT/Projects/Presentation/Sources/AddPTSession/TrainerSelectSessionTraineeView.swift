//
//  TrainerSelectSessionTraineeView.swift
//  Presentation
//
//  Created by 박민서 on 2/6/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI

import Domain
import DesignSystem

/// TrainerAppPTSessionView에서 사용하는 회원 선택용 바텀 시트 뷰
public struct TrainerSelectSessionTraineeView: View {
    /// 회원 리스트
    var traineeList: [(listItem: TraineeListItemEntity, action: () -> Void)]
    /// 선택된 회원 id
    var selectedTraineeId: Int?
    /// 바텀시트 높이
    @State private var contentHeight: CGFloat = 708
    /// 최대 높이
    let maxHeight: CGFloat = 708
    /// 최소 높이
    let minHeight: CGFloat = 206
    
    @Environment(\.dismiss) var dismiss
    
    public init(
        traineeList: [(listItem: TraineeListItemEntity, action: () -> Void)],
        selectedTraineeId: Int? = nil
    ) {
        self.traineeList = traineeList
        self.selectedTraineeId = selectedTraineeId
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header()
            
            if contentHeight >= 708 {
                ScrollView {
                    Contents()
                }
            } else {
                Contents()
            }
            
            Spacer(minLength: 0)
        }
        .padding(.top, 24)
        .presentationDetents([.height(contentHeight)])
        .presentationDragIndicator(contentHeight == maxHeight ? .visible : .hidden)
    }
    
    // MARK: Section
    @ViewBuilder
    private func Header() -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("회원 선택하기")
                    .typographyStyle(.heading3, with: .neutral900)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(.icnDelete)
                        .renderingMode(.template)
                        .resizable()
                        .tint(.neutral400)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(20)
            TDivider(height: 2, color: .neutral100)
        }
    }
    
    @ViewBuilder
    private func Contents() -> some View {
        VStack(spacing: 0) {
            ForEach(traineeList, id: \.listItem.id) { item in
                TraineeListItem(
                    isSelected: item.listItem.id == selectedTraineeId,
                    name: item.listItem.name,
                    action: item.action
                )
                .frame(height: 56)
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        updateHeight(with: proxy.size.height)
                    }
                    .onChange(of: proxy.size.height) { _, newHeight in
                        updateHeight(with: newHeight)
                    }
            }
        )
    }
}

private extension TrainerSelectSessionTraineeView {
    /// 바텀 시트 높이 업데이트 함수
    func updateHeight(with newHeight: CGFloat) {
        var newHeight: CGFloat = newHeight
        newHeight = newHeight < minHeight ? minHeight : newHeight
        contentHeight = newHeight >= maxHeight ? maxHeight : newHeight
    }
}

private extension TrainerSelectSessionTraineeView {
    struct TraineeListItem: View {
        let isSelected: Bool
        let name: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 0) {
                    Text(name)
                        .typographyStyle(.body1Semibold, with: .neutral600)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    if isSelected {
                        Image(.icnCheckMarkFilled)
                            .resizable()
                            .frame(width: 32, height: 32)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}
