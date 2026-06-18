//
//  OnboardingScreenView.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//

import SwiftUI

struct OnboardingScreenView: View {
    @StateObject private var viewMoel = OnboardingViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("RadientPrimary"), Color("RadientSecondary"),
                ]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                HStack(spacing: 6) {
                    ForEach(viewMoel.onboardingItems.indices, id: \.self) {
                        index in
                        let isActive: Bool = viewMoel.currentStep == index

                        Capsule()
                            .fill(
                                Color("SubContent").opacity(isActive ? 1 : 0.4)
                            )
                            .frame(
                                width: isActive ? 26 : 6,
                                height: 6
                            )
                    }
                }
                .padding(.bottom, 5)
                CustomButton(
                    buttonColor: Color("Button"),
                    title: "Continue",
                    shadowColor: Color("Button"),
                    action: {
                        print("OK")
                    }
                )
            }
            .padding(.horizontal, 20)

            if #available(iOS 26.0, *) {
                Button(action: {
                    print("Đã bấm nút bên trái!")
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .frame(width: 20, height: 30)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(.leading, 20)
                .padding(.top, 5)
            } else {
                Button(action: {
                    print("Đã bấm nút bên trái!")
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .frame(width: 20, height: 30)
                }
                .buttonBorderShape(.circle)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(.leading, 20)
                .padding(.top, 5)
            }

        }

    }
}
