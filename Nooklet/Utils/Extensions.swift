//
//  Extensions.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func applyScrollEdgeEffectStyle() -> some View {
        if #available(iOS 26.0, *) {
            self.scrollEdgeEffectStyle(.automatic, for: .all)
        } else {
            self
        }
    }
}

extension View {
    @ViewBuilder
    func borderBeam(
        border: Color,
        hideFadeBorder: Bool = true,
        beam: [Color],
        beamBlur: CGFloat,
        cornerRadius: CGFloat,
        isEnabled: Bool = true
    ) -> some View {
        self
            .modifier(
                BorderBeamEffect(
                    border: border,
                    hideFadeBorder: hideFadeBorder,
                    beam: beam,
                    beamBlur: beamBlur,
                    cornerRadius: cornerRadius,
                    isEnabled: isEnabled
                )
            )
    }
}

struct BorderBeamEffect: ViewModifier {
    var border: Color
    var hideFadeBorder: Bool
    var beam: [Color]
    var beamBlur: CGFloat
    var cornerRadius: CGFloat
    var isEnabled: Bool
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {

                    if !hideFadeBorder {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(border.tertiary, lineWidth: 0.6)
                    }

                    //USING KEYFRAME
                    if isEnabled {
                        KeyframeAnimator(initialValue: 0.0, repeating: true) {
                            value in
                            let rotation = value * 360
                            let borderGradient = AngularGradient(
                                colors: [.clear, border, .clear],
                                center: .center,
                                startAngle: .degrees(140 + rotation),
                                endAngle: .degrees(270 + rotation)
                            )

                            let beamGradient = LinearGradient(
                                colors: beam,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )

                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(beamGradient)
                                .mask {
                                    Rectangle()
                                        .overlay {
                                            Rectangle()
                                                .blur(radius: beamBlur)
                                                .blendMode(.destinationOut)
                                        }
                                }
                                .mask {
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .fill(borderGradient)
                                        .blur(radius: beamBlur / 1.5)
                                        .padding(-beamBlur * 2)
                                }

                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(borderGradient, lineWidth: 0.6)
                        } keyframes: { _ in
                            LinearKeyframe(1, duration: 2.5)
                        }
                    }

                }
            }
    }
}
extension Color {
    init(hex string: String) {
        var string: String = string.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }

        // Double the last value if incomplete hex
        if !string.count.isMultiple(of: 2), let last = string.last {
            string.append(last)
        }

        // Fix invalid values
        if string.count > 8 {
            string = String(string.prefix(8))
        }

        // Scanner creation
        let scanner = Scanner(string: string)

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        if string.count == 2 {
            let mask = 0xFF

            let g = Int(color) & mask

            let gray = Double(g) / 255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)

        } else if string.count == 4 {
            let mask = 0x00FF

            let g = Int(color >> 8) & mask
            let a = Int(color) & mask

            let gray = Double(g) / 255.0
            let alpha = Double(a) / 255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)

        } else if string.count == 6 {
            let mask = 0x0000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)

        } else if string.count == 8 {
            let mask = 0x0000_00FF
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            let alpha = Double(a) / 255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)

        } else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        }
    }
}
