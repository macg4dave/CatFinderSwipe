import SwiftUI

struct CachedAsyncImageView: View {
    let url: URL
    var contentMode: ContentMode = .fill
    var cornerRadius: CGFloat = 0

    @State private var uiImage: UIImage?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if let errorMessage {
                ContentUnavailableView("Couldn’t load image", systemImage: "wifi.exclamationmark", description: Text(errorMessage))
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
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
