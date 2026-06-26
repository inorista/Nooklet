//
//  RegisterScreenView.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//

import SwiftUI

struct RegisterUserView: View {

    enum Field: Hashable, CaseIterable {
        case firstName
        case lastName
    }

    @FocusState private var focusedField: Field?
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = RegisterScreenViewModel()

    var body: some View {
        ZStack {
            CinematicBackground()

            ScrollView(showsIndicators: false) {
                VStack {
                    VStack(spacing: 32) {
                        Spacer(minLength: 40)

                        // Welcome Title
                        VStack(spacing: 8) {
                            Text("JOIN THE")
                                .font(
                                    .system(
                                        size: 13,
                                        weight: .bold,
                                        design: .rounded
                                    )
                                )
                                .tracking(4.0)
                                .foregroundStyle(.white.opacity(0.5))

                            Text("Nooklet")
                                .font(
                                    .system(
                                        size: 48,
                                        weight: .black,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .white.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        AvatarSection()
                            .padding(.vertical, 8)

                        // Fields Container
                        VStack(spacing: 16) {
                            CustomTextField(
                                placeholder: "First Name",
                                text: $viewModel.firstName,
                                icon: "person.fill",
                                focusBinding: $focusedField,
                                field: .firstName,
                                submitLabel: .next
                            )
                            CustomTextField(
                                placeholder: "Last Name",
                                text: $viewModel.lastName,
                                icon: "person.text.rectangle.fill",
                                focusBinding: $focusedField,
                                field: .lastName,
                                submitLabel: .done
                            )
                        }
                        .padding(24)
                        .background(Color.black.opacity(0.3))
                        .background(.ultraThinMaterial)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                        )
                        .onSubmit {
                            moveToNextField()
                        }

                        Spacer(minLength: 40)

                        // Premium Button
                        Button {
                            UIImpactFeedbackGenerator(style: .rigid)
                                .impactOccurred()
                            Task {
                                await viewModel.onRegister()
                                coordinator.onRegistrationCompleted()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Continue")
                                    .font(
                                        .system(
                                            size: 18,
                                            weight: .bold,
                                            design: .rounded
                                        )
                                    )
                                    .foregroundStyle(.black)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.black)
                                Spacer()
                            }
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 24,
                                    style: .continuous
                                )
                            )
                            .shadow(
                                color: .white.opacity(0.2),
                                radius: 10,
                                x: 0,
                                y: 5
                            )
                        }
                        .buttonStyle(BouncyCardStyle())
                        .opacity(viewModel.isFormValid ? 1 : 0.5)
                        .disabled(!viewModel.isFormValid)
                        .animation(
                            .easeInOut(duration: 0.3),
                            value: viewModel.isFormValid
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .frame(maxWidth: 450)
                }
                .frame(maxWidth: .infinity)
            }
            .applyScrollEdgeEffectStyle()
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $viewModel.isAvatarSheetPresented) {
            AvatarPickerSheet()
        }
    }

    private func moveToNextField() {
        guard let currentField = focusedField else { return }
        let allFields = Field.allCases
        guard let currentIndex = allFields.firstIndex(of: currentField) else {
            return
        }

        let nextIndex = currentIndex + 1
        if nextIndex < allFields.count {
            focusedField = allFields[nextIndex]
        } else {
            focusedField = nil
            if viewModel.isFormValid {
                Task {
                    await viewModel.onRegister()
                    coordinator.onRegistrationCompleted()
                }
            }
        }
    }

    @ViewBuilder
    func AvatarSection() -> some View {
        VStack(spacing: 16) {
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                viewModel.isAvatarSheetPresented = true
            }) {
                ZStack(alignment: .bottomTrailing) {
                    Image(viewModel.selectedAvatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.5),
                                            .white.opacity(0.1),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(
                            color: .black.opacity(0.4),
                            radius: 12,
                            x: 0,
                            y: 6
                        )

                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle().stroke(
                                    .white.opacity(0.2),
                                    lineWidth: 1
                                )
                            )

                        Image(systemName: "camera.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: 0, y: 0)
                }
            }
            .buttonStyle(BouncyCardStyle())

            Text("Select an avatar")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    @ViewBuilder
    func AvatarPickerSheet() -> some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.07).ignoresSafeArea()

            VStack(spacing: 24) {
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 48, height: 5)
                    .padding(.top, 12)

                Text("Choose Your Avatar")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                let columns = Array(
                    repeating: GridItem(.flexible(), spacing: 20),
                    count: 4
                )

                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(viewModel.avatars, id: \.self) { avatar in
                        let isSelected = viewModel.selectedAvatar == avatar
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light)
                                .impactOccurred()
                            withAnimation(
                                .spring(response: 0.4, dampingFraction: 0.7)
                            ) {
                                viewModel.selectAvatar(avatar)
                            }
                        }) {
                            Image(avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isSelected
                                                ? Color.white
                                                : Color.white.opacity(0.1),
                                            lineWidth: isSelected ? 3 : 1
                                        )
                                )
                                .scaleEffect(isSelected ? 1.15 : 1.0)
                                .shadow(
                                    color: isSelected
                                        ? .white.opacity(0.3) : .clear,
                                    radius: 10,
                                    x: 0,
                                    y: 4
                                )
                                .opacity(isSelected ? 1.0 : 0.7)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                Spacer()
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(36)
    }
}

#Preview {
    RegisterUserView()
}
