import SwiftUI

struct CachedAsyncImageView: View {
    let url: URL
    var contentMode: ContentMode = .fill
    /// If non-nil, clips the image with this corner radius. Prefer clipping at the card level.
    var cornerRadius: CGFloat? = nil

    @State private var uiImage: UIImage?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Prevent white flashes while loading.
            Color.black.opacity(0.04)
                .drawingGroup()

            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFillIfNeeded(contentMode)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .clipped()
            } else if let errorMessage {
                ContentUnavailableView("Couldn’t load image", systemImage: "wifi.exclamationmark", description: Text(errorMessage))
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .drawingGroup()
        .ifLet(cornerRadius) { view, radius in
            view.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        }
        .task(id: url) {
            errorMessage = nil
            do {
                uiImage = try await ImagePipeline.shared.image(for: url)
            } catch {
                uiImage = nil
                errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
}

private extension Image {
    @ViewBuilder
    func scaledToFillIfNeeded(_ contentMode: ContentMode) -> some View {
        switch contentMode {
        case .fill:
            self.scaledToFill()
        case .fit:
            self.scaledToFit()
        @unknown default:
            self.scaledToFill()
        }
    }
}
