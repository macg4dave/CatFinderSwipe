import SwiftUI

enum StableColor {
    /// A deterministic, preview-friendly random color derived from a stable key.
    static func color(for key: String) -> Color {
        // 12 pleasant-ish colors.
        let palette: [Color] = [
            Color(red: 0.98, green: 0.83, blue: 0.83),
            Color(red: 0.98, green: 0.90, blue: 0.78),
            Color(red: 0.98, green: 0.96, blue: 0.78),
            Color(red: 0.84, green: 0.95, blue: 0.82),
            Color(red: 0.78, green: 0.93, blue: 0.95),
            Color(red: 0.80, green: 0.87, blue: 0.99),
            Color(red: 0.86, green: 0.80, blue: 0.98),
            Color(red: 0.96, green: 0.82, blue: 0.95),
            Color(red: 0.92, green: 0.92, blue: 0.92),
            Color(red: 0.97, green: 0.88, blue: 0.90),
            Color(red: 0.88, green: 0.95, blue: 0.90),
            Color(red: 0.88, green: 0.90, blue: 0.98),
        ]

        let idx = abs(key.hashValue) % palette.count
        return palette[idx]
    }
}
