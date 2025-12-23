import SwiftUI

/// A lightweight overlay that emits floating cat emojis when triggered.
struct EmojiBurstView: View {
    struct Particle: Identifiable {
        let id = UUID()
        let emoji: String
        let x: CGFloat
        let size: CGFloat
        let duration: Double
    }

    /// Increment this value to trigger a new burst.
    let trigger: Int

    private let emojis: [String] = ["😺", "😸", "😻", "🐱", "🐈", "🐾"]

    @State private var particles: [Particle] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    EmojiParticleView(
                        particle: particle,
                        containerSize: geo.size,
                        onComplete: { id in
                            particles.removeAll { $0.id == id }
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(false)
            .onChange(of: trigger) { _, _ in
                spawnBurst(containerWidth: geo.size.width)
            }
        }
    }

    private func spawnBurst(containerWidth: CGFloat) {
        let count = Int.random(in: 6...11)
        var new: [Particle] = []
        new.reserveCapacity(count)

        for _ in 0..<count {
            let emoji = emojis.randomElement() ?? "😺"
            let x = CGFloat.random(in: 24...(max(24, containerWidth - 24)))
            let size = CGFloat.random(in: 22...44)
            let duration = Double.random(in: 1.2...2.2)
            new.append(Particle(emoji: emoji, x: x, size: size, duration: duration))
        }

        particles.append(contentsOf: new)
    }
}

private struct EmojiParticleView: View {
    let particle: EmojiBurstView.Particle
    let containerSize: CGSize
    let onComplete: (UUID) -> Void

    @State private var y: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        Text(particle.emoji)
            .font(.system(size: particle.size))
            .position(x: particle.x, y: y)
            .opacity(opacity)
            .onAppear {
                y = containerSize.height + 20
                opacity = 1

                // Animate upward.
                withAnimation(.easeOut(duration: particle.duration)) {
                    y = -40
                }
                // Fade near the end.
                withAnimation(.easeIn(duration: particle.duration * 0.45).delay(particle.duration * 0.55)) {
                    opacity = 0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + particle.duration + 0.1) {
                    onComplete(particle.id)
                }
            }
    }
}
