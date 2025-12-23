import SwiftUI

struct CachedAsyncImageView: View {
    let url: URL
    var contentMode: ContentMode = .fill
    /// If non-nil, clips the image with this corner radius. Prefer clipping at the card level.
    var cornerRadius: CGFloat? = nil

    @State private var uiImage: UIImage?
    @State private var errorMessage: String?
    @State private var containerSize: CGSize = .zero

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
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear { containerSize = proxy.size }
                    .onChange(of: proxy.size) { _, newValue in
                        containerSize = newValue
                    }
            }
        )
        .drawingGroup()
        .ifLet(cornerRadius) { view, radius in
            view.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        }
        .task(id: taskIdentity) {
            errorMessage = nil
            do {
                if let maxPixel = requestedMaxPixelSize {
                    uiImage = try await ImagePipeline.shared.image(for: url, maxPixelSize: maxPixel)
                } else {
                    uiImage = try await ImagePipeline.shared.image(for: url)
                }
            } catch {
                uiImage = nil
                errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
        }
    }

    private var requestedMaxPixelSize: Int? {
        // Avoid requesting while layout is unresolved.
        guard containerSize.width > 1, containerSize.height > 1 else { return nil }

        // Convert points -> pixels.
        let scale = UIScreen.main.scale
        let maxPoints = max(containerSize.width, containerSize.height)
        var pixels = Int(ceil(maxPoints * scale))

        // Clamp and bucket to reduce the number of variants.
        pixels = max(256, min(2048, pixels))
        let bucket = 128
        pixels = ((pixels + bucket - 1) / bucket) * bucket
        return pixels
    }

    private var taskIdentity: String {
        // Changing size bucket should reload with an appropriately scaled image.
        if let maxPixel = requestedMaxPixelSize {
            return url.absoluteString + "|mps=\(maxPixel)"
        }
        return url.absoluteString
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
