import SwiftUI
import SwiftData

struct ChatHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \ChatSession.updatedAt, order: .reverse) private var sessions: [ChatSession]
    
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sessions) { session in
                    Button(action: {
                        viewModel.loadSession(session)
                        dismiss()
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\(session.messages.count) messages")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteSessions)
            }
            .navigationTitle("Lịch sử Chat")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Đóng") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.createNewSession()
                        dismiss()
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .overlay {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "Không có lịch sử",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Bắt đầu cuộc trò chuyện mới để lưu lại lịch sử.")
                    )
                }
            }
        }
    }
    
    private func deleteSessions(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let session = sessions[index]
                if session.id == viewModel.currentSession?.id {
                    viewModel.createNewSession()
                }
                modelContext.delete(session)
            }
        }
    }
}
