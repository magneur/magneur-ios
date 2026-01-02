//
//  ArcMenuView.swift
//  Magneur
//
//  Created by Andrew on 02.01.2026.
//

import SwiftUI

/// Preference key to collect arc item positions for hit-testing.
struct ArcItemPositionsKey: PreferenceKey {
    static var defaultValue: [AppSection: CGPoint] = [:]
    
    static func reduce(value: inout [AppSection: CGPoint], nextValue: () -> [AppSection: CGPoint]) {
        value.merge(nextValue()) { $1 }
    }
}

/// A vertical arc menu that appears on the left edge of the screen.
/// Icons are positioned along the arc using trigonometry.
struct ArcMenuView: View {
    /// Currently highlighted section (tracks finger position).
    let selected: AppSection?
    
    /// Callback when user selects a section.
    let onSelect: (AppSection) -> Void
    
    /// Callback to report item positions for accurate hit-testing.
    var onPositionsCalculated: (([AppSection: CGPoint]) -> Void)? = nil
    
    var body: some View {
        GeometryReader { geo in
            let config = ArcConfiguration(size: geo.size)
            
            ZStack {
                // Arc background stroke
                Path { path in
                    path.addArc(
                        center: config.center,
                        radius: config.radius,
                        startAngle: .radians(config.startAngle),
                        endAngle: .radians(config.endAngle),
                        clockwise: false
                    )
                }
                .stroke(
                    Color.white.opacity(0.2),
                    style: StrokeStyle(lineWidth: 60, lineCap: .round)
                )
                .blur(radius: 3)
                
                // Section icons along the arc
                ForEach(Array(AppSection.allCases.enumerated()), id: \.element) { index, section in
                    let position = config.position(for: index)
                    
                    ArcMenuItem(
                        section: section,
                        isSelected: selected == section,
                        position: position
                    )
                }
            }
            .onAppear {
                // Compute and report all positions
                var positions: [AppSection: CGPoint] = [:]
                for (index, section) in AppSection.allCases.enumerated() {
                    positions[section] = config.position(for: index)
                }
                onPositionsCalculated?(positions)
            }
            .preference(key: ArcItemPositionsKey.self, value: computePositions(config: config))
        }
        .ignoresSafeArea()
    }
    
    private func computePositions(config: ArcConfiguration) -> [AppSection: CGPoint] {
        var positions: [AppSection: CGPoint] = [:]
        for (index, section) in AppSection.allCases.enumerated() {
            positions[section] = config.position(for: index)
        }
        return positions
    }
}

/// Configuration for arc geometry calculations.
private struct ArcConfiguration {
    let size: CGSize
    
    /// Radius of the arc.
    var radius: CGFloat {
        min(size.width * 0.6, size.height * 0.4)
    }
    
    /// Center point at left edge of screen.
    var center: CGPoint {
        CGPoint(x: 0, y: size.height / 2)
    }
    
    /// Start angle in radians (-70° from horizontal, upper right quadrant).
    /// Using negative angle to start from top.
    var startAngle: Double {
        -.pi * 0.4  // -72° (points up-right)
    }
    
    /// End angle in radians (+70° from horizontal, lower right quadrant).
    var endAngle: Double {
        .pi * 0.4   // +72° (points down-right)
    }
    
    /// Angle step between items.
    var angleStep: Double {
        (endAngle - startAngle) / Double(AppSection.allCases.count - 1)
    }
    
    /// Calculate position for item at given index.
    func position(for index: Int) -> CGPoint {
        let angle = startAngle + Double(index) * angleStep
        return CGPoint(
            x: center.x + radius * CGFloat(cos(angle)),
            y: center.y + radius * CGFloat(sin(angle))
        )
    }
}

/// Individual menu item with icon and optional label.
private struct ArcMenuItem: View {
    let section: AppSection
    let isSelected: Bool
    let position: CGPoint
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Glow effect when selected
                if isSelected {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.4), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                }
                
                Image(systemName: section.icon)
                    .font(.system(size: isSelected ? 48 : 36, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
            }
            
            Text(section.rawValue)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
        }
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .position(x: position.x, y: position.y)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.8)
        ArcMenuView(selected: .finance, onSelect: { _ in })
    }
}
