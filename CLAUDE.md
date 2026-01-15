# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is a native Xcode project with no external dependencies (no CocoaPods, SPM packages, or Carthage).

```bash
# Open in Xcode
open Magneur/Magneur.xcodeproj

# Build from command line
xcodebuild -project Magneur/Magneur.xcodeproj -scheme Magneur -destination 'platform=iOS Simulator,name=iPhone 16'

# Run tests
xcodebuild test -project Magneur/Magneur.xcodeproj -scheme Magneur -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture

### Two-Layer Design

The app uses a deliberate two-layer architecture designed for future AI integration (see `context_graph_architecture.md`):

1. **Domain Layer** - Traditional SwiftData models optimized for UI. Fast, offline-first, normalized.
2. **Context Layer** (planned) - Will store Facts and DecisionTraces for AI reasoning. Observer pattern will bridge domains to this layer.

### Section-Based Structure

The app has five sections defined in `AppSection` enum: Fitness, Finance, ToDo, Journal, Travel. Currently only Fitness is implemented; others are placeholders.

Each section should follow this pattern (demonstrated in Fitness):
- `Sections/{Name}/` - Section root
  - `{Name}View.swift` - Main section view
  - `CommonModels/` - Domain models (value types)
  - `Storage/` - SwiftData models and store singleton
  - `ViewModels/` - Observable state managers
  - `Views/` - SwiftUI views organized by feature
  - `HealthKit/` - External integrations (if applicable)

### Navigation

- `AppRouter` - Simple observable managing `currentSection`
- `ArcMenuView` - Custom gesture-based radial menu for section switching
- Navigation within sections uses standard SwiftUI NavigationStack

### Data Persistence

- **SwiftData** with automatic CloudKit sync (`cloudKitDatabase: .automatic`)
- Models configured in `MagneurApp.swift` via `ModelContainer`
- Pattern: Store singleton (e.g., `WorkoutStore.shared`) configured with `ModelContext` on app launch
- Domain models ↔ Stored models conversion via initializers and `toStoredX()` methods

### State Management

- `@Observable` for shared state (AppRouter, stores)
- Singleton pattern for data stores
- View-local `@State` for UI state

## Key Patterns

### Domain vs Stored Models
Domain models (e.g., `Workout`) are value types with business logic. Stored models (e.g., `StoredWorkout`) are `@Model` classes for SwiftData. Complex nested data (exercises) stored as JSON strings due to SwiftData limitations.

### Store Singleton Pattern
```swift
@Observable
final class SectionStore {
    static let shared = SectionStore()
    private var modelContext: ModelContext?

    func configure(with context: ModelContext) {
        self.modelContext = context
    }
    // fetch, save, delete methods...
}
```

## Testing

Uses Swift Testing framework (`@Test` macro). Test targets exist but are minimal. Tests run via Xcode or `xcodebuild test`.
