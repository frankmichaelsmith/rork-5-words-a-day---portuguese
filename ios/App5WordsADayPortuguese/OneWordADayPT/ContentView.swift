import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: AppViewModel?
    @State private var selectedTab: Int = 0

    var body: some View {
        Group {
            if let viewModel {
                TabView(selection: $selectedTab) {
                    Tab("Learn", systemImage: "sun.max.fill", value: 0) {
                        DailyWordsView(viewModel: viewModel, selectedTab: $selectedTab)
                    }

                    Tab("Review", systemImage: "arrow.clockwise", value: 1) {
                        ReviewView(viewModel: viewModel)
                    }

                    Tab("Recall", systemImage: "brain.head.profile.fill", value: 2) {
                        RecallView(viewModel: viewModel)
                    }

                    Tab("Words", systemImage: "book.closed.fill", value: 3) {
                        VocabularyListView(viewModel: viewModel)
                    }

                    Tab("Stats", systemImage: "chart.bar.fill", value: 4) {
                        DashboardView(viewModel: viewModel)
                    }
                }
            } else {
                ProgressView()
                    .onAppear {
                        if viewModel == nil {
                            viewModel = AppViewModel(modelContext: modelContext)
                        }
                    }
            }
        }
    }
}
