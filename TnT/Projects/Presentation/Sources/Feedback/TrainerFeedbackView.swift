//
//  TrainerFeedbackView.swift
//  Presentation
//
//  Created by 박서연 on 2/15/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import DesignSystem

struct TrainerFeedbackView: View {
    
    public var store: StoreOf<TrainerFeedbackFeature>
    
    public init(store: StoreOf<TrainerFeedbackFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Header()
            ScrollView(showsIndicators: false) {
                EmptyRecord()
                    .frame(minHeight: UIScreen.main.bounds.height - 204)
            }
        }
        .background(Color.neutral100)
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder
    private func Header() -> some View {
        HStack(spacing: 6) {
            Text("피드백")
                .typographyStyle(.heading2, with: .neutral900)
            Text("0")
                .typographyStyle(.heading2, with: Color.red500)
            Spacer()
        }
        .padding(20)
    }
    
    @ViewBuilder
    private func EmptyRecord() -> some View {
        VStack(spacing: 4) {
            Text("아직 등록된 기록이 없어요")
                .typographyStyle(.body2Bold, with: Color.neutral600)
            Text("트레이니가 기록을 전송하면 여기에 표시돼요!")
                .typographyStyle(.label1Medium, with: Color.neutral400)
        }
    }
}
