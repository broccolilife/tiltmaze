import SwiftUI

struct LoadingView: View {
    var message: String = "Loading…"

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(.quaternary, lineWidth: 4)
                    .frame(width: 48, height: 48)

                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(.tint, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: isAnimating)
            }

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { isAnimating = true }
    }
}

#Preview {
    LoadingView()
}
