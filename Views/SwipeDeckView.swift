import SwiftUI
import SwiftData

struct SwipeDeckView: View {
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel: SwipeDeckViewModel

    @State private var dragOffset: CGSize = .zero
    @State private var isCommittingSwipe: Bool = false

    init(api: CatAPIClientProtocol = CataasAPIClient()) {
        // ModelContext is only available at runtime, so we build the store in init using the environment later.
        // We initialize with a lightweight placeholder store; it’ll be replaced on appear.
        let placeholderContainer = try? ModelContainer(for: Schema([FavoriteCat.self, SeenCat.self]), configurations: [])
        let placeholderContext = placeholderContainer.map { ModelContext($0) } ?? ModelContext(try! ModelContainer(for: Schema([FavoriteCat.self, SeenCat.self])))
        _viewModel = StateObject(wrappedValue: SwipeDeckViewModel(api: api, store: CatDecisionStore(modelContext: placeholderContext)))
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            content
                .padding()
        }
        .navigationTitle("Cats")
        .toolbar {
            NavigationLink {
                FavoritesView()
            } label: {
                Label("Favorites", systemImage: "heart.fill")
            }
        }
        .onAppear {
            // Swap in the real store backed by the app’s ModelContext.
            viewModel.replaceStore(CatDecisionStore(modelContext: modelContext))
            viewModel.start()
        }
    }

    @ViewBuilder
    private var content: some View {
        if let errorMessage = viewModel.errorMessage {
            VStack(spacing: 12) {
                ContentUnavailableView("Couldn’t load cats", systemImage: "wifi.exclamationmark", description: Text(errorMessage))
                Button("Retry") { viewModel.retry() }
                    .buttonStyle(.borderedProminent)
            }
        } else if viewModel.isLoading && viewModel.current == nil {
            ProgressView("Loading cats…")
        } else if let current = viewModel.current {
            GeometryReader { geo in
                let cardSize = CGSize(
                    width: min(geo.size.width, 520),
                    height: min(geo.size.height, 720)
                )

                ZStack {
                    // Only show the next card once the swipe commit is done.
                    if !isCommittingSwipe, let next = viewModel.next {
                        CatCardView(card: next, backgroundColor: viewModel.backgroundColor)
                            .frame(width: cardSize.width, height: cardSize.height)
                            .scaleEffect(0.98)
                            .opacity(0.6)
                            .zIndex(0)
                    }

                    CatCardView(card: current, backgroundColor: viewModel.backgroundColor)
                        .frame(width: cardSize.width, height: cardSize.height)
                        .offset(dragOffset)
                        .rotationEffect(.degrees(Double(dragOffset.width / 20)))
                        .zIndex(1)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    guard !isCommittingSwipe else { return }
                                    dragOffset = value.translation
                                }
                                .onEnded { value in
                                    guard !isCommittingSwipe else { return }
                                    handleDragEnded(value)
                                }
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: dragOffset)
        } else {
            ContentUnavailableView("No cats", systemImage: "cat")
        }
    }

    private func handleDragEnded(_ value: DragGesture.Value) {
        let threshold: CGFloat = 120
        let translation = value.translation

        if translation.width > threshold {
            isCommittingSwipe = true
            withAnimation { dragOffset = CGSize(width: 800, height: translation.height) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                dragOffset = .zero
                viewModel.swipeRight()
                isCommittingSwipe = false
            }
        } else if translation.width < -threshold {
            isCommittingSwipe = true
            withAnimation { dragOffset = CGSize(width: -800, height: translation.height) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                dragOffset = .zero
                viewModel.swipeLeft()
                isCommittingSwipe = false
            }
        } else {
            withAnimation { dragOffset = .zero }
        }
    }
}

#Preview {
    NavigationStack {
        SwipeDeckView()
    }
    .modelContainer(for: [FavoriteCat.self, SeenCat.self], inMemory: true)
}
