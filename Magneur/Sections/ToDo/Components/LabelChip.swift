import SwiftUI

struct LabelChip: View {
    let label: String
    var onRemove: (() -> Void)?

    var body: some View {
        HStack(spacing: 4) {
            Text("#\(label)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.9))

            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.indigo.opacity(0.7))
        )
    }
}

struct LabelInput: View {
    @Binding var labels: [String]
    @State private var newLabel = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Existing labels
            if !labels.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(labels, id: \.self) { label in
                        LabelChip(label: label) {
                            labels.removeAll { $0 == label }
                        }
                    }
                }
            }

            // Input field
            HStack {
                Image(systemName: "tag")
                    .foregroundStyle(.secondary)

                TextField("Add label", text: $newLabel)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onSubmit {
                        addLabel()
                    }

                if !newLabel.isEmpty {
                    Button(action: addLabel) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
            )
        }
    }

    private func addLabel() {
        let cleaned = newLabel
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "#", with: "")
            .lowercased()

        if !cleaned.isEmpty && !labels.contains(cleaned) {
            labels.append(cleaned)
        }
        newLabel = ""
    }
}

// Simple flow layout for label chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)

        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    // Move to next row
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack {
            LabelChip(label: "shopping")
            LabelChip(label: "work") { }
            LabelChip(label: "personal") { }
        }

        LabelInput(labels: .constant(["shopping", "urgent", "home"]))
    }
    .padding()
}
