import SwiftUI
import SwiftData

struct SwipeDeckView: View {
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel: SwipeDeckViewModel

    @State private var dragOffset: CGSize = .zero

    private enum Layout {
        static let cardWidthFraction: CGFloat = 0.95
        static let cardHeightFraction: CGFloat = 0.75
        static let cardCornerRadius: CGFloat = 20
    }

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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
            GeometryReader { proxy in
                let cardWidth = proxy.size.width * Layout.cardWidthFraction
                let cardHeight = proxy.size.height * Layout.cardHeightFraction
                let shape = RoundedRectangle(cornerRadius: Layout.cardCornerRadius, style: .continuous)

                ZStack {
                    if let next = viewModel.next {
                        CatCardView(card: next, backgroundColor: viewModel.backgroundColor)
                            .frame(width: cardWidth, height: cardHeight)
                            .clipShape(shape)
                            .contentShape(shape)
                            .overlay(shape.strokeBorder(.quaternary))
                            .scaleEffect(0.98)
                            .opacity(0.6)
                    }

                    CatCardView(card: current, backgroundColor: viewModel.backgroundColor)
                        .frame(width: cardWidth, height: cardHeight)
                        .clipShape(shape)
                        .contentShape(shape)
                        .overlay(shape.strokeBorder(.quaternary))
                        .offset(dragOffset)
                        .rotationEffect(.degrees(Double(dragOffset.width / 20)))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation
                                }
                                .onEnded { value in
                                    handleDragEnded(value)
                                }
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
            withAnimation { dragOffset = CGSize(width: 800, height: translation.height) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                dragOffset = .zero
                Haptics.swipeCommitLike()
                viewModel.swipeRight()
            }
        } else if translation.width < -threshold {
            withAnimation { dragOffset = CGSize(width: -800, height: translation.height) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                dragOffset = .zero
                Haptics.swipeCommitNope()
                viewModel.swipeLeft()
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
