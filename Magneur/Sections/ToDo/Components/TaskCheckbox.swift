import SwiftUI

struct TaskCheckbox: View {
    let isCompleted: Bool
    let priority: TaskPriority
    let onToggle: () -> Void

    @State private var isAnimating = false

    private var priorityColor: Color {
        Color(hex: priority.color) ?? .gray
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isAnimating = true
            }
            onToggle()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
        }) {
            ZStack {
                // Outer ring
                Circle()
                    .strokeBorder(
                        isCompleted ? priorityColor : priorityColor.opacity(0.5),
                        lineWidth: 2
                    )
                    .frame(width: 24, height: 24)

                // Fill when completed
                if isCompleted {
                    Circle()
                        .fill(priorityColor)
                        .frame(width: 20, height: 20)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)

                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .scaleEffect(isAnimating ? 1.3 : 1.0)
                }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isCompleted)
    }
}

#Preview {
    VStack(spacing: 20) {
        TaskCheckbox(isCompleted: false, priority: .p1) {}
        TaskCheckbox(isCompleted: true, priority: .p1) {}
        TaskCheckbox(isCompleted: false, priority: .p2) {}
        TaskCheckbox(isCompleted: true, priority: .p2) {}
        TaskCheckbox(isCompleted: false, priority: .p3) {}
        TaskCheckbox(isCompleted: false, priority: .p4) {}
    }
    .padding()
    .background(.black)
}
