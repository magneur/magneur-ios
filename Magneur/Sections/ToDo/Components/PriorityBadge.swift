import SwiftUI

struct PriorityBadge: View {
    let priority: TaskPriority

    private var color: Color {
        Color(hex: priority.color) ?? .gray
    }

    var body: some View {
        if priority != .p4 {  // Don't show badge for lowest priority
            Text(priority.displayName)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(color)
                )
        }
    }
}

struct PriorityPicker: View {
    @Binding var priority: TaskPriority

    var body: some View {
        HStack(spacing: 8) {
            ForEach(TaskPriority.allCases, id: \.self) { p in
                Button {
                    priority = p
                } label: {
                    Text(p.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(priority == p ? .white : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(priority == p ? Color(hex: p.color) ?? .gray : Color(.systemGray5))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 10) {
            PriorityBadge(priority: .p1)
            PriorityBadge(priority: .p2)
            PriorityBadge(priority: .p3)
            PriorityBadge(priority: .p4)
        }

        PriorityPicker(priority: .constant(.p2))
    }
    .padding()
}
