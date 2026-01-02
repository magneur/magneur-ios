# Magneur Context Graph Architecture

**Goal**: Transform Magneur into a "System of Record for Decisions"—a digital twin that captures not just what happened, but *why*.

---

## 1. Evolution of Thinking (Reasoning & Decisions)

This architecture is the result of iterating on several key insights about how AI agents differ from traditional software.

### Insight 1: The "Two Clocks" Problem
**Initial Challenge**: Traditional apps only store **State** (what is true right now). If a user changes a workout goal or a budget, the old value is overwritten.
**The Gap**: LLMs need the **Event Clock** (what happened, in what order, and why). Without history, an AI is like a lawyer who knows the verdict but has no case files.
**Decision**: We must store data in two parallel ways: the current state for the app, and the event history for the AI.

### Insight 2: Context Graphs vs. Knowledge Graphs
**Initial Challenge**: Getting data to the LLM. Standard RAG (Retrieval Augmented Generation) retrieves documents based on similarity, which is often imprecise.
**The Solution (from Foundation Capital & PlayerZero)**: We need a **Context Graph** that captures decision traces.
**Refinement (from Graphlit)**: It's not just a graph of nodes. It requires a specific three-layer structure:
1. **Content**: The evidence (workout logs, transactions).
2. **Entities**: The nouns (exercises, stores, people).
3. **Facts**: The assertions ("User is getting stronger", "Spending increased").
**Decision**: We won't just dump JSON into a vector DB. We will extract structured **Facts** with temporal validity (`validAt` / `invalidAt`).

### Insight 3: Separation of Concerns (The Final Pivot)
**Initial Challenge**: Trying to build one monolithic database that serves both the fast, interactive iOS UI and the slow, reasoning-heavy LLM.
**The Friction**: LLMs need denormalized, verbose context. iOS apps need highly normalized, indexed data for performance.
**The Breakthrough**: **Decouple the systems.**
*   **Domain Layer**: Traditional SwiftData models. Optimized for the iPhone screen.
*   **Context Layer**: A separate observer system. It watches the Domain Layer and "projects" important changes into the Context Graph as Facts.
**Why this wins**: You can build the "Fitness" feature today without worrying about AI. Later, you add a `FitnessObserver` that connects it to the brain. It's modular and safe.

---

## 2. Core Architecture

### High-Level Diagram

```mermaid
graph TB
    subgraph "App World (Fast, Structured)"
        UI[SwiftUI Views]
        D_FIT[Fitness Domain]
        D_FIN[Finance Domain]
        D_TODO[Todo Domain]
    end

    subgraph "The Bridge"
        OBS[Context Observers]
    end

    subgraph "AI World (Deep, Temporal)"
        CG[Context Graph Service]
        FACTS[Fact Store (ValidAt/InvalidAt)]
        TRACES[Decision Traces (Why?)]
        LLM[Gemini / Digital Twin]
    end

    UI --> D_FIT
    UI --> D_FIN
    UI --> D_TODO

    D_FIT -.->|Notifies| OBS
    D_FIN -.->|Notifies| OBS

    OBS -->|Extracts Facts| CG
    CG --> FACTS
    CG --> TRACES
    
    LLM <-->|Queries| CG
```

### The Two Layers

#### A. Domain Layer (The Body)
*   **Technology**: SwiftData / CloudKit.
*   **Purpose**: Power the UI. Fast, offline-first.
*   **Structure**: Normalized tables (Workout, Exercise, Transaction).
*   **Philosophy**: "Source of Truth for State."

#### B. Context Graph Layer (The Brain)
*   **Technology**: SwiftData / CloudKit (Separate Models).
*   **Purpose**: Power the Agent. History-aware.
*   **Structure**:
    *   **Fact**: `text: "Bench Press 1RM is 100kg"`, `validAt: 2024-01-01`.
    *   **DecisionTrace**: `action: "Skipped workout"`, `reason: "Injury recovery"`.
*   **Philosophy**: "Source of Truth for Reasoning."

---

## 3. Data Models (Context Layer)

These models live alongside your domain models but serve the AI.

### The Fact (Atom of Knowledge)
Instead of storing "Current Weight", we store a timeline of weight facts.

```swift
struct Fact: Identifiable, Codable {
    let id: UUID
    let content: String        // "Net worth is $50,000"
    let validAt: Date          // When did this become true?
    var invalidAt: Date?       // When did it stop being true? (nil = currently true)
    let confidence: Double     // 1.0 = User said so, 0.7 = AI inferred it
    let source: FactSource     // .user, .inference, .system
    
    // Graph Connections
    let relatedEntityIDs: [UUID] // Links to "Finance", "Saving Account"
}
```

### The Decision Trace (The Why)
Captures the logic behind changes.

```swift
struct DecisionTrace: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let action: String         // "Decreased calorie goal"
    let reasoning: String      // "User reported feeling fatigued consistently"
    let supportingFactIDs: [UUID] // Links to facts used to make this decision
}
```

---

## 4. Implementation Strategy

### Phase 1: The Context Infrastructure
Build the "Brain" container first. It doesn't need to know about Fitness or Finance yet. It just needs to know how to store `Facts` and `Traces`.

### Phase 2: Domain + Bridge
1. Build the **Fitness Domain** (standard iOS dev).
2. Create a `FitnessContextObserver`.
3. When user saves a workout -> Observer triggers -> Creates a `Fact` ("Completed heavy chest day").

### Phase 3: The Digital Twin (LLM)
Connect the LLM to the **Context Layer**, not the **Domain Layer**.
*   **User**: "How am I progressing?"
*   **LLM**: Queries `FactStore` for all facts related to "Fitness" ordered by `validAt`.
*   **Result**: The LLM sees the *story* of your fitness, not just the final numbers.

---

## 5. Storage & Sync

*   **CloudKit Private Database**: Used for both layers.
    *   **Cost**: Free for developer (uses user's iCloud).
    *   **Privacy**: Best-in-class. You don't see their data.
    *   **Sync**: Automatic across their devices.

## 6. Future Proofing
Any new domain (Travel, Journal) simply needs a new *Observer* to plug into the Brain. The Brain never needs rewriting.
