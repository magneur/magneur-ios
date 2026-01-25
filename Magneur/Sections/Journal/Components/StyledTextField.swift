//
//  StyledTextField.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Styled text field with optional underline and number prefix
struct StyledTextField: View {
    @Binding var text: String
    let placeholder: String
    var number: Int? = nil
    var showUnderline: Bool = true
    var isTitle: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let number = number {
                Text("\(number).")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 4) {
                TextField(placeholder, text: $text, axis: .vertical)
                    .font(isTitle ? .headline.weight(.bold) : .body)
                    .foregroundStyle(.white)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.leading)
                    .lineLimit(isTitle ? 1 : 3)

                if showUnderline {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.white.opacity(0.2))
                }
            }
        }
        .padding(.vertical, 8)
    }
}

/// Large text area for longer content
struct StyledTextArea: View {
    @Binding var text: String
    let placeholder: String
    var minHeight: CGFloat = 120

    var body: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .font(.body)
            .foregroundStyle(.white)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .frame(minHeight: minHeight, alignment: .topLeading)
            .padding(16)
            .background(.ultraThinMaterial.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
    }
}

/// Section header with styling
struct StyledSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline)
            .italic()
            .foregroundStyle(.white.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.purple, .pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(spacing: 24) {
                StyledTextField(
                    text: .constant("My Title"),
                    placeholder: "Enter title...",
                    isTitle: true
                )

                StyledTextField(
                    text: .constant("First item"),
                    placeholder: "Enter item...",
                    number: 1
                )

                StyledTextArea(
                    text: .constant(""),
                    placeholder: "Describe your scene in detail..."
                )
            }
            .padding()
        }
    }
}
