//
//  BouncyCardStyle.swift
//  Nooklet
//
//  Created by Tu on 25/6/26.
//

import Foundation
import SwiftUI
struct BouncyCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .brightness(configuration.isPressed ? -0.1 : 0)
            .animation(
                .spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0),
                value: configuration.isPressed
            )
    }
}
