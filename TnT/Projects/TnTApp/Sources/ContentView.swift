//
//  ContentView.swift
//  TnTAPP
//
//  Created by 박서연 on 1/4/25.
//  Copyright © 2025 yapp25-app2team. All rights reserved.
//

import SwiftUI
import Presentation
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
                TrainerHomeView(store: Store(initialState: TrainerHomeFeature.State(), reducer: {
                    TrainerHomeFeature()
                }))
//                TrainerMypageView(store: Store(initialState: TrainerMypageFeature.State(
//                    userName: "홍길동",
//                            userImageUrl: nil,
//                            studentCount: 10,
//                            oldStudentCount: 5,
//                            appPushNotificationAllowed: true,
//                            versionInfo: "1.0.0"
//                    ), reducer: {
//                    TrainerMypageFeature()
//                }))
    }
}
