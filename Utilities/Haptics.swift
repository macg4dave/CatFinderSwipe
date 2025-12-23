import Foundation
import UIKit

/// Lightweight haptics helper.
///
/// Keep this UIKit-based for broad compatibility and predictable behavior.
enum Haptics {
    static func swipeCommitLike() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    static func swipeCommitNope() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    static func undo() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}
