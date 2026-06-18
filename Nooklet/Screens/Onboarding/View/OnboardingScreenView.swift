//
//  OnboardingScreenView.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//
import SwiftUI

struct OnboardingScreenView: View {
    @ObservedObject private var viewModel = OnboardingViewModel()

    var animation: Animation {
        .interpolatingSpring(duration: 0.65, bounce: 0, initialVelocity: 0)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            RadientBackground()
            BodyContent()
            BackButton()
        }
    }

    @ViewBuilder
    func BackButton() -> some View {
        if viewModel.currentStep > 0 {
            if #available(iOS 26.0, *) {
                Button(action: {
                    withAnimation(animation) {
                        viewModel.onBackPressed()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .frame(width: 20, height: 30)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .glassEffect()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                ).animation(
                    .bouncy(duration: 0.75),
                    value: viewModel.currentStep != 0
                )

                .opacity(viewModel.currentStep != 0 ? 1 : 0)
                .padding(.leading, 20)
                .padding(.top, 5)
            } else {
                Button(action: {
                    withAnimation(animation) {
                        viewModel.onBackPressed()
                    }
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
                .animation(
                    .bouncy(duration: 0.75),
                    value: viewModel.currentStep != 0
                )
                .opacity(viewModel.currentStep != 0 ? 1 : 0)
                .padding(.leading, 20)
                .padding(.top, 5)
            }
        }
    }

    @ViewBuilder
    func BodyContent() -> some View {
        VStack(spacing: 10) {
            GeometryReader {
                let size = $0.size
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(
                            viewModel.onboardingItems.indices,
                            id: \.self
                        ) {
                            index in

                            let currentItem = viewModel.onboardingItems[
                                index
                            ]
                            let isActive = viewModel.currentStep == index

                            VStack(spacing: 6) {
                                Spacer()
                                Image(currentItem.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: viewModel.currentStep == 2 ? 250 : 320)
                                    .padding(.all, 20)
                                    .shadow(
                                        color: Color(.white).opacity(0.4),
                                        radius: 20,
                                        x: 10,
                                        y: 10,
                                    )

                                Spacer()
                                Text(currentItem.title)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .foregroundColor(Color(.subContent))

                                Text(currentItem.description)
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(
                                        Color(.subContent).opacity(0.8)
                                    )
                                    .padding(.horizontal, 12)
                            }
                            .frame(width: size.width)
                            .compositingGroup()
                            .blur(radius: isActive ? 0 : 30)
                            .opacity(isActive ? 1 : 0)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollDisabled(true)
                .scrollTargetBehavior(.paging)
                .scrollPosition(
                    id: .init(
                        get: {
                            return viewModel.currentStep
                        },
                        set: {
                            _ in
                        }
                    )
                )
            }

            HStack(spacing: 6) {
                ForEach(viewModel.onboardingItems.indices, id: \.self) {
                    index in
                    let isActive: Bool = viewModel.currentStep == index
                    Capsule()
                        .fill(
                            Color(.subContent).opacity(isActive ? 1 : 0.4)
                        )
                        .frame(
                            width: isActive ? 26 : 6,
                            height: 6
                        )
                        .animation(.bouncy(duration: 0.5), value: isActive)

                }
            }
            .padding(.bottom, 5)
            .padding(.top, 10)

            CustomButton(
                buttonColor: Color(.button),
                title: viewModel.currentStep == 2 ? "Get Started" : "Continue",
                shadowColor: Color(.button),
                action: {
                    withAnimation(animation) {
                        viewModel.onContinuePressed()
                    }
                }
            )
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
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
