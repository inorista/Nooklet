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
            RadientBackground()
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                    AvatarSection()
                    VStack(spacing: 16) {
                        CustomTextField(
                            placeholder: "First Name",
                            text: $viewModel.firstName,
                            icon: "person",
                            focusBinding: $focusedField,
                            field: .firstName,
                            submitLabel: .next
                        )
                        CustomTextField(
                            placeholder: "Last Name",
                            text: $viewModel.lastName,
                            icon: "person.text.rectangle",
                            focusBinding: $focusedField,
                            field: .lastName,
                            submitLabel: .done
                        )
                    }
                    .onSubmit {
                        moveToNextField()
                    }
                    Spacer()
                    CustomButton(
                        buttonColor: Color(.button),
                        title: "Continue",
                        shadowColor: Color(.button),
                        action: {
                            Task {
                                await viewModel.onRegister()
                                coordinator.onRegistrationCompleted()
                            }
                        }
                    )
                    .opacity(viewModel.isFormValid ? 1 : 0.5)
                    .disabled(!viewModel.isFormValid)
                    .animation(
                        .easeInOut(duration: 0.3),
                        value: viewModel.isFormValid
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .padding(.bottom, 40)
            }
            .applyScrollEdgeEffectStyle()
            .scrollDismissesKeyboard(.interactively)
            .safeAreaPadding(.top)
        }
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
        VStack(spacing: 14) {
            Button(action: {
                viewModel.isAvatarSheetPresented = true
            }) {
                ZStack(alignment: .bottomTrailing) {
                    Image(viewModel.selectedAvatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(.border), lineWidth: 2)
                        )
                        .shadow(
                            color: Color(.info).opacity(0.3),
                            radius: 12,
                            x: 0,
                            y: 6
                        )

                    ZStack {
                        Circle()
                            .fill(Color(.button))
                            .frame(width: 30, height: 30)
                        Image(systemName: "pencil")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color(.buttonContent))
                    }
                    .offset(x: 4, y: 4)
                }
            }
            .buttonStyle(.plain)

            Text("Tap to choose avatar")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(.subContent))
        }
    }

    // MARK: - Birthday Picker
    @ViewBuilder
    func BirthdayPicker() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Birthday")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(.subContent))
                .padding(.leading, 4)

            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(.placeHolder))
                    .frame(width: 20)

                DatePicker(
                    "",
                    selection: $viewModel.birthday,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(Color(.info))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
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

    @ViewBuilder
    func AvatarPickerSheet() -> some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color(.border))
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            Text("Choose Your Avatar")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(.content))

            let columns = Array(
                repeating: GridItem(.flexible(), spacing: 16),
                count: 4
            )

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.avatars, id: \.self) { avatar in
                    let isSelected = viewModel.selectedAvatar == avatar
                    Button(action: {
                        withAnimation(
                            .spring(response: 0.35, dampingFraction: 0.7)
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
                                            ? Color(.info) : Color(.border),
                                        lineWidth: isSelected ? 3 : 1
                                    )
                            )
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                            .shadow(
                                color: isSelected
                                    ? Color(.info).opacity(0.4) : .clear,
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            Spacer()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(28)
        .background(Color(.background))
    }

    // MARK: - Background
    @ViewBuilder
    func RadientBackground() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.radientPrimary), Color(.radientSecondary),
            ]),
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .drawingGroup()
        .ignoresSafeArea()
    }
}
