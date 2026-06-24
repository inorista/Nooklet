import SwiftUI

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var birthDay: Date
    @State private var selectedAvatar: String
    @State private var isAvatarSheetPresented: Bool = false
    
    let avatars: [String] = (1...15).map { "avatar\($0)" }
    let onSave: (String, String, Date, String) -> Void
    
    init(user: User, onSave: @escaping (String, String, Date, String) -> Void) {
        _firstName = State(initialValue: user.firstName)
        _lastName = State(initialValue: user.lastName)
        _birthDay = State(initialValue: user.birthDay)
        _selectedAvatar = State(initialValue: user.imageData ?? "avatar1")
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.background).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Tappable Avatar
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            isAvatarSheetPresented = true
                        }) {
                            ZStack(alignment: .bottomTrailing) {
                                Image(selectedAvatar)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.5), .white.opacity(0.1)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)

                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.6))
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Circle().stroke(.white.opacity(0.2), lineWidth: 1)
                                        )

                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                .offset(x: 0, y: 0)
                            }
                        }
                        .buttonStyle(BouncyCardStyle())
                        .padding(.top, 32)

                        Text("Tap to change avatar")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                        
                        VStack(spacing: 16) {
                            customTextField(title: "First Name", text: $firstName)
                            customTextField(title: "Last Name", text: $lastName)
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onSave(firstName, lastName, birthDay, selectedAvatar)
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .disabled(firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .preferredColorScheme(.dark)
            .sheet(isPresented: $isAvatarSheetPresented) {
                AvatarPickerSheet()
            }
        }
    }
    
    private func customTextField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .padding(.leading, 8)
            
            TextField(title, text: text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }

    // MARK: - Avatar Picker Sheet (same design as Register)

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
                    ForEach(avatars, id: \.self) { avatar in
                        let isSelected = selectedAvatar == avatar
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                selectedAvatar = avatar
                            }
                            isAvatarSheetPresented = false
                        }) {
                            Image(avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isSelected ? Color.white : Color.white.opacity(0.1),
                                            lineWidth: isSelected ? 3 : 1
                                        )
                                )
                                .scaleEffect(isSelected ? 1.15 : 1.0)
                                .shadow(
                                    color: isSelected ? .white.opacity(0.3) : .clear,
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
