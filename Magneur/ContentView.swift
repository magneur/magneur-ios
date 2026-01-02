//
//  ContentView.swift
//  Magneur
//
//  Created by Andrew on 02.01.2026.
//

import SwiftUI

/// Main container view with arc menu gesture handling.
struct ContentView: View {
    /// Router managing current section.
    @State private var router = AppRouter()
    
    /// Whether the arc menu is currently displayed.
    @State private var showMenu = false
    
    /// Currently highlighted section during drag.
    @State private var selectedSection: AppSection?
    
    /// Stored positions of arc menu items for hit-testing.
    @State private var itemPositions: [AppSection: CGPoint] = [:]
    
    /// Edge threshold for triggering menu (points from left edge).
    private let edgeThreshold: CGFloat = 50
    
    /// Minimum drag distance to activate menu.
    private let activationDistance: CGFloat = 30
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Current section content
                SectionContentView(section: router.currentSection)
                    .animation(.easeInOut(duration: 0.3), value: router.currentSection)
                
                // Menu overlay
                if showMenu {
                    // Dimmed background
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    // Arc menu
                    ArcMenuView(
                        selected: selectedSection,
                        onSelect: { section in
                            navigateTo(section)
                        },
                        onPositionsCalculated: { positions in
                            itemPositions = positions
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.8, anchor: .leading)),
                        removal: .opacity.combined(with: .scale(scale: 0.9, anchor: .leading))
                    ))
                }
            }
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        handleDragChanged(value: value, in: geo.size)
                    }
                    .onEnded { value in
                        handleDragEnded(value: value)
                    }
            )
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showMenu)
        }
    }
    
    // MARK: - Gesture Handling
    
    private func handleDragChanged(value: DragGesture.Value, in size: CGSize) {
        // Check if gesture started near left edge and moved right
        if !showMenu {
            if value.startLocation.x < edgeThreshold && value.translation.width > activationDistance {
                showMenu = true
            }
        }
        
        // Update selection based on current finger position
        if showMenu {
            selectedSection = findClosestSection(to: value.location, in: size)
        }
    }
    
    private func handleDragEnded(value: DragGesture.Value) {
        guard showMenu else { return }
        
        // Check for cancel gesture (quick swipe back left)
        let velocityThreshold: CGFloat = -200
        if value.predictedEndLocation.x - value.location.x < velocityThreshold {
            // Cancel - don't navigate
            withAnimation {
                showMenu = false
                selectedSection = nil
            }
            return
        }
        
        // Navigate to selected section if any
        if let section = selectedSection {
            navigateTo(section)
        } else {
            withAnimation {
                showMenu = false
            }
        }
    }
    
    private func navigateTo(_ section: AppSection) {
        router.currentSection = section
        withAnimation {
            showMenu = false
            selectedSection = nil
        }
    }
    
    // MARK: - Hit Testing
    
    /// Find the closest section to the given point using stored positions.
    private func findClosestSection(to point: CGPoint, in size: CGSize) -> AppSection? {
        // If we have computed positions, use Euclidean distance
        if !itemPositions.isEmpty {
            var closestSection: AppSection?
            var closestDistance: CGFloat = .infinity
            
            for (section, position) in itemPositions {
                let distance = hypot(point.x - position.x, point.y - position.y)
                if distance < closestDistance {
                    closestDistance = distance
                    closestSection = section
                }
            }
            
            // Only return if within reasonable distance (150pt)
            if closestDistance < 150 {
                return closestSection
            }
            return nil
        }
        
        // Fallback: simple vertical mapping
        let normalizedY = point.y / size.height
        let index = Int(normalizedY * CGFloat(AppSection.allCases.count))
        let clampedIndex = max(0, min(index, AppSection.allCases.count - 1))
        return AppSection.allCases[clampedIndex]
    }
}

#Preview {
    ContentView()
}
