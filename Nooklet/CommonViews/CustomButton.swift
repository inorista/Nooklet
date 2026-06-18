//
//  CustomButton.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//

import SwiftUI

struct CustomButton: View {
    let cornerRadius: CGFloat?
    let shadowColor: Color?
    let titleColor: Color?
    let buttonColor: Color?
    let title: String
    let action: () -> Void
    let buttonWidth: CGFloat?
    let fontSize: CGFloat?

    init(
        buttonColor: Color? = nil,
        title: String,
        titleColor: Color? = nil,
        cornerRadius: CGFloat? = nil,
        shadowColor: Color? = nil,
        buttonWidth: CGFloat? = nil,
        fontSize: CGFloat? = nil,
        action: @escaping () -> Void
    ) {
        self.buttonColor = buttonColor
        self.title = title
        self.action = action
        self.titleColor = titleColor
        self.shadowColor = shadowColor
        self.cornerRadius = cornerRadius
        self.buttonWidth = buttonWidth ?? .infinity
        self.fontSize = fontSize
    }

    var body: some View {
        Button(
            action: action,
            label: {
                Text(self.title)
                    .font(.system(size: fontSize ?? 16))
                    .foregroundStyle(self.titleColor ?? Color("ButtonContent"))
                    .padding(.all, 14)
                    .frame(maxWidth: buttonWidth)
            }
        )
        .buttonStyle(.borderedProminent)
        .tint(buttonColor)
        .shadow(color: shadowColor ?? .clear, radius: 4, x: 0, y: 0)
        .cornerRadius(self.cornerRadius ?? 12, corners: .allCorners)
    }
}
