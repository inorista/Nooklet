//
//  CustomTextField.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//

import SwiftUI

struct CustomTextField<Field: Hashable>: View {
    let placeholder: String
    @Binding var text: String
    let icon: String?
    var focusBinding: FocusState<Field?>.Binding
    let field: Field
    var submitLabelStyle: SubmitLabel

    init(
        placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        focusBinding: FocusState<Field?>.Binding,
        field: Field,
        submitLabel: SubmitLabel = .done
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.focusBinding = focusBinding
        self.field = field
        self.submitLabelStyle = submitLabel
    }

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(.placeHolder))
                    .frame(width: 20)
            }

            TextField(
                "",
                text: $text,
                prompt:
                    Text(placeholder)
                    .foregroundStyle(Color(.placeHolder))
            )
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(Color(.content))
            .focused(focusBinding, equals: field)
            .submitLabel(submitLabelStyle)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.surface))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(.border), lineWidth: 1)
        )
    }
}
