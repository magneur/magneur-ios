import Foundation

struct Project: Codable, Identifiable, Hashable {
    var id: String?
    var name: String
    var color: String
    var iconName: String
    var sortOrder: Int
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String? = nil,
        name: String,
        color: String = "#5856D6",  // Default indigo
        iconName: String = "folder.fill",
        sortOrder: Int = 0,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.iconName = iconName
        self.sortOrder = sortOrder
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Factory Methods

    static func inbox() -> Project {
        Project(
            id: "inbox",
            name: "Inbox",
            color: "#007AFF",
            iconName: "tray.fill",
            sortOrder: -1
        )
    }

    // MARK: - Predefined Colors

    static let availableColors: [(name: String, hex: String)] = [
        ("Red", "#FF3B30"),
        ("Orange", "#FF9500"),
        ("Yellow", "#FFCC00"),
        ("Green", "#34C759"),
        ("Teal", "#5AC8FA"),
        ("Blue", "#007AFF"),
        ("Indigo", "#5856D6"),
        ("Purple", "#AF52DE"),
        ("Pink", "#FF2D55"),
        ("Gray", "#8E8E93")
    ]

    // MARK: - Predefined Icons

    static let availableIcons: [String] = [
        "folder.fill",
        "briefcase.fill",
        "house.fill",
        "heart.fill",
        "star.fill",
        "flag.fill",
        "bookmark.fill",
        "tag.fill",
        "cart.fill",
        "gift.fill",
        "graduationcap.fill",
        "book.fill",
        "pencil",
        "laptopcomputer",
        "gamecontroller.fill",
        "music.note",
        "camera.fill",
        "airplane",
        "car.fill",
        "figure.run"
    ]
}
