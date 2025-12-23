import Foundation
import Network
import Combine

/// Lightweight reachability monitor for friendly offline messaging.
///
/// Uses `NWPathMonitor` (no third-party deps). Updates are delivered on the main thread.
@MainActor
final class NetworkMonitor: ObservableObject {
    @Published private(set) var isConnected: Bool = true
    @Published private(set) var statusText: String = "Online"

    private let monitor: NWPathMonitor
    private let queue: DispatchQueue

    init() {
        self.monitor = NWPathMonitor()
        self.queue = DispatchQueue(label: "CatFinderSwipe.NetworkMonitor")

        monitor.pathUpdateHandler = { [weak self] path in
            let connected = (path.status == .satisfied)
            let statusText: String
            if connected {
                statusText = "Online"
            } else {
                statusText = "Offline"
            }

            Task { @MainActor in
                self?.isConnected = connected
                self?.statusText = statusText
            }
        }

        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
