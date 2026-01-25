//
//  BulletPointListEditor.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editable list of numbered bullet points
struct BulletPointListEditor: View {
    @Binding var items: [String]
    let sectionTitle: String
    let placeholder: String
    var canAddRemove: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            StyledSectionHeader(title: sectionTitle)

            VStack(spacing: 12) {
                ForEach(items.indices, id: \.self) { index in
                    HStack(alignment: .top) {
                        StyledTextField(
                            text: Binding(
                                get: { items[index] },
                                set: { items[index] = $0 }
                            ),
                            placeholder: placeholder,
                            number: index + 1
                        )

                        if canAddRemove && items.count > 1 {
                            Button {
                                withAnimation {
                                    _ = items.remove(at: index)
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.white.opacity(0.5))
                                    .font(.title3)
                            }
                            .padding(.top, 12)
                        }
                    }
                }

                if canAddRemove {
                    Button {
                        withAnimation {
                            items.append("")
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.white.opacity(0.8))
                            Text("Add Item")
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding(.top, 8)
                    }
                }
            }
        }
    }
}

/// Paired list editor for old/new assumptions
struct AssumptionPairEditor: View {
    @Binding var oldItems: [String]
    @Binding var newItems: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                StyledSectionHeader(title: "Old Assumptions")

                ForEach(oldItems.indices, id: \.self) { index in
                    HStack(alignment: .top) {
                        StyledTextField(
                            text: Binding(
                                get: { oldItems[index] },
                                set: { oldItems[index] = $0 }
                            ),
                            placeholder: "I used to believe...",
                            number: index + 1
                        )

                        if oldItems.count > 1 {
                            Button {
                                withAnimation {
                                    _ = oldItems.remove(at: index)
                                    if index < newItems.count {
                                        _ = newItems.remove(at: index)
                                    }
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.white.opacity(0.5))
                                    .font(.title3)
                            }
                            .padding(.top, 12)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 16) {
                StyledSectionHeader(title: "New Assumptions")

                ForEach(newItems.indices, id: \.self) { index in
                    StyledTextField(
                        text: Binding(
                            get: { newItems[index] },
                            set: { newItems[index] = $0 }
                        ),
                        placeholder: "Now I know...",
                        number: index + 1
                    )
                }
            }

            Button {
                withAnimation {
                    oldItems.append("")
                    newItems.append("")
                }
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.white.opacity(0.8))
                    Text("Add Assumption Pair")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.top, 8)
            }
        }
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
            VStack(spacing: 32) {
                BulletPointListEditor(
                    items: .constant(["First outcome", "Second outcome", ""]),
                    sectionTitle: "Desired Outcomes",
                    placeholder: "Enter outcome..."
                )

                AssumptionPairEditor(
                    oldItems: .constant(["I can't do this", ""]),
                    newItems: .constant(["I am capable", ""])
                )
            }
            .padding()
        }
    }
}
