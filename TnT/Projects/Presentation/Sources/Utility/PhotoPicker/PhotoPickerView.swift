//
//  PhotoPickerView.swift
//  Presentation
//
//  Created by 박민서 on 2/17/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

public struct PhotoPickerView<Content: View>: View {
    
    private let store: StoreOf<PhotoLibraryFeature>
    @Binding private var selectedItem: PhotosPickerItem?
    private let content: () -> Content
    
    public init(
        store: StoreOf<PhotoLibraryFeature>,
        selectedItem: Binding<PhotosPickerItem?>,
        content: @escaping () -> Content
    ) {
        self.store = store
        self._selectedItem = selectedItem
        self.content = content
    }

    public var body: some View {
        ZStack {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                content()
            }

            if !store.isAuthorized {
                Color.black.opacity(0.00001)
                    .onTapGesture {
                        store.send(.requestPermission)
                    }
            }
        }
        .onAppear {
            store.send(.checkPermission)
        }
    }
}
