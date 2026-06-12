import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var viewModel = RecordingViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    statusBanner
                    controls
                    TranscriptView(
                        partial: viewModel.partialTranscript,
                        final: viewModel.finalTranscript
                    )
                    BenchmarkPanelView(snapshot: viewModel.benchmark)
                }
                .padding()
            }
            .navigationTitle("Nemotron ASR")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    // MARK: - Sections

    private var statusBanner: some View {
        HStack(spacing: 8) {
            Circle().fill(viewModel.statusColor).frame(width: 10, height: 10)
            Text(viewModel.statusMessage).font(.subheadline)
            Spacer()
            if viewModel.status.isBusy { ProgressView() }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Picker(
                    "Language",
                    selection: Binding(
                        get: { viewModel.selectedLanguage },
                        set: { viewModel.setLanguage($0) }
                    )
                ) {
                    ForEach(ASRLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .pickerStyle(.menu)
                .disabled(viewModel.isSessionActive || viewModel.isTranscribingFile)

                Picker(
                    "Tier",
                    selection: Binding(
                        get: { viewModel.selectedTier },
                        set: { viewModel.selectedTier = $0 }
                    )
                ) {
                    ForEach(StreamingTier.allCases) { t in
                        Text(t.displayName).tag(t)
                    }
                }
                .pickerStyle(.menu)
                .disabled(viewModel.isSessionActive || viewModel.isTranscribingFile)
            }

            HStack(spacing: 12) {
                Button {
                    Task { await viewModel.start() }
                } label: {
                    Label("Start", systemImage: "mic.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canStart)

                Button {
                    Task { await viewModel.stop() }
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.status != .recording)

                Button {
                    viewModel.clear()
                } label: {
                    Label("Clear", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isSessionActive || viewModel.isTranscribingFile)
            }

            HStack(spacing: 12) {
                Button {
                    viewModel.showFileImporter()
                } label: {
                    Label("Import File", systemImage: "doc.badge.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isSessionActive || viewModel.isTranscribingFile)

                if viewModel.isTranscribingFile {
                    Button(role: .cancel) {
                        viewModel.cancelTranscription()
                    } label: {
                        Label("Cancel", systemImage: "xmark.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .fileImporter(
            isPresented: Binding(
                get: { viewModel.isImportingFile },
                set: { _ in viewModel.dismissFileImporter() }
            ),
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    viewModel.importFile(url: url)
                }
            case .failure(let error):
                viewModel.handleImportError(error)
            }
        }
    }
}

#Preview {
    ContentView()
}
