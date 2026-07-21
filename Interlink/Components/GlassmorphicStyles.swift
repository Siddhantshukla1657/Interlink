import SwiftUI

// MARK: - Glassmorphic Modifiers & Views

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 12

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.8), .white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

struct GlassPillModifier: ViewModifier {
    var isSelected: Bool
    var activeColor: Color = Color(red: 0.1, green: 0.45, blue: 0.95)

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? AnyShapeStyle(activeColor) : AnyShapeStyle(.ultraThinMaterial))
            )
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : Color.white.opacity(0.6),
                        lineWidth: 1
                    )
            )
            .shadow(color: isSelected ? activeColor.opacity(0.25) : Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

struct GlassBackground: View {
    var body: some View {
        ZStack {
            // Soft gradient canvas backdrop
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.95, blue: 0.98),
                    Color(red: 0.94, green: 0.93, blue: 0.96),
                    Color(red: 0.97, green: 0.96, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Subtle luminous orb glows for glass reflections
            Circle()
                .fill(Color.blue.opacity(0.08))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: -120, y: -200)

            Circle()
                .fill(Color.purple.opacity(0.06))
                .frame(width: 320, height: 320)
                .blur(radius: 70)
                .offset(x: 140, y: 180)
        }
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 16, padding: CGFloat = 12) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius, padding: padding))
    }

    func glassPill(isSelected: Bool, activeColor: Color = Color(red: 0.1, green: 0.45, blue: 0.95)) -> some View {
        self.modifier(GlassPillModifier(isSelected: isSelected, activeColor: activeColor))
    }
}
