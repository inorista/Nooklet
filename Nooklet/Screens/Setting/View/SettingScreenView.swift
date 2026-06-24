import SwiftUI

struct SettingScreenView: View {
    @StateObject private var viewModel = SettingScreenViewModel()
    @State private var showEditProfile = false
    
    var body: some View {
        ZStack {
            Color(.background).ignoresSafeArea()
            
            Circle()
                .fill(Color.blue.opacity(0.1))
                .blur(radius: 60)
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(Color.purple.opacity(0.1))
                .blur(radius: 60)
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 300)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    HStack {
                        Text("Settings")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    profileCard
                    
                    //appSettingsCard

                    Spacer(minLength: 40)
                }
            }
        }
        .sheet(isPresented: $showEditProfile) {
            if let user = viewModel.currentUser {
                EditProfileSheet(user: user) { newFirstName, newLastName, newBirthDay, newAvatar in
                    viewModel.updateProfile(firstName: newFirstName, lastName: newLastName, birthDay: newBirthDay, imageData: newAvatar)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var profileCard: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            showEditProfile = true
        }) {
            HStack(spacing: 20) {
                Image(viewModel.currentUser?.imageData ?? "avatar1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
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
                
                VStack(alignment: .leading, spacing: 6) {
                    if let user = viewModel.currentUser {
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(user.birthDay, style: .date)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    } else {
                        Text("Loading Profile...")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.4))
                    .font(.system(size: 16, weight: .bold))
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(BouncyCardStyle())
        .padding(.horizontal, 24)
    }
    
    private var appSettingsCard: some View {
        VStack(spacing: 0) {
            SettingRow(icon: "bell.fill", title: "Notifications", color: .red)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 24)
    }
}

// A simple row for general settings
struct SettingRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .bold))
            }
            
            Text(title)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.4))
                .font(.system(size: 14, weight: .bold))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}

#Preview {
    SettingScreenView()
        .preferredColorScheme(.dark)
}
