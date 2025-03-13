//
//  TraineeDietRecordDetailView.swift
//  Presentation
//
//  Created by 박민서 on 2/12/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI

import Domain
import DesignSystem

/// 식단 기록을 추가하는 화면
@ViewAction(for: TraineeDietRecordDetailFeature.self)
public struct TraineeDietRecordDetailView: View {
    
    @Bindable public var store: StoreOf<TraineeDietRecordDetailFeature>
    @Environment(\.dismiss) var dismiss: DismissAction
    
    /// `TraineeDietRecordDetailView` 생성자
    /// - Parameter store: `TraineeDietRecordDetailFeature`와 연결된 Store
    public init(store: StoreOf<TraineeDietRecordDetailFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            TNavigation(
                type: .LRButtonWithTitle(
                    leftImage: .icnArrowLeft,
                    centerTitle: "\(store.dietDate?.toString(format: .M월_d일) ?? "")",
                    rightImage: .icnEllipsis
                ),
                leftAction: {
                    dismiss()
                },
                rightAction: {
                    send(.tapEllipsisButton)
                }
            )
            
            VStack(spacing: 8) {
                ImageSection()
                
                ContentSection()
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            send(.onAppear)
        }
    }
    
    // MARK: - Sections
    @ViewBuilder
    private func ImageSection() -> some View {
        AsyncImage(url: store.dietImageURL) { phase in
            switch phase {
            case .empty:
                if store.dietImageURL != nil {
                    ProgressView()
                        .tint(.red500)
                        .padding(20)
                } else {
                    EmptyView()
                }
                
            case .success(let image):
                GeometryReader { geometry in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipShape(.rect(cornerRadius: 20))
                }
                .aspectRatio(1.0, contentMode: .fit)
                .padding(20)
                
            case .failure(let error):
                EmptyView()
                
            @unknown default:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private func ContentSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                if let chipInfo = store.dietType?.chipInfo {
                    TChip(uiInfo: chipInfo)
                }
                HStack(spacing: 8) {
                    Text(store.dietDate?.toString(format: .yyyyMMddSlash) ?? "")
                        .typographyStyle(.body2Medium, with: .neutral600)
                    Text(store.dietDate?.toString(format: .a_HHmm) ?? "")
                        .typographyStyle(.body2Medium, with: .neutral600)
                    Spacer()
                }
                .frame(height: 42)
            }
            
            TDivider(height: 2, color: .neutral100)
                .padding(.vertical, 8)
            
            Text(store.dietInfo)
                .typographyStyle(.body1Medium, with: .neutral800)
        }
        .padding(.horizontal, 20)
    }
}
