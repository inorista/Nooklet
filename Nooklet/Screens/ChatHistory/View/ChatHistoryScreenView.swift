//
//  ChatHistoryScreenView.swift
//  Nooklet
//
//  Created by Tu on 23/6/26.
//

import SwiftUI

struct ChatHistoryScreenView: View {
    var body: some View {
        ZStack {
            RadientBackground()
        }
        .navigationTitle("Chat History")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func RadientBackground() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.radientPrimary), Color(.radientSecondary),
            ]),
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()
    }
}

#Preview {
    ChatHistoryScreenView()
}
