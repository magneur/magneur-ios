import SwiftUI

struct ProjectEditorView: View {
    let project: Project?  // nil = creating new
    let onSave: (Project) -> Void
    let onDelete: (() -> Void)?

    @State private var name: String
    @State private var selectedColor: String
    @State private var selectedIcon: String
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss

    init(project: Project?, onSave: @escaping (Project) -> Void, onDelete: (() -> Void)?) {
        self.project = project
        self.onSave = onSave
        self.onDelete = onDelete
        _name = State(initialValue: project?.name ?? "")
        _selectedColor = State(initialValue: project?.color ?? Project.availableColors[5].hex)  // Default blue
        _selectedIcon = State(initialValue: project?.iconName ?? "folder.fill")
    }

    private var isEditing: Bool {
        project != nil
    }

    var body: some View {
        NavigationStack {
            List {
                // Preview
                Section {
                    HStack {
                        Spacer()
                        ProjectPreview(name: name, color: selectedColor, icon: selectedIcon)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }

                // Name
                Section("Project Name") {
                    TextField("Enter project name", text: $name)
                }

                // Color picker
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(Project.availableColors, id: \.hex) { colorOption in
                            ColorPickerButton(
                                color: colorOption.hex,
                                isSelected: selectedColor == colorOption.hex
                            ) {
                                selectedColor = colorOption.hex
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Icon picker
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(Project.availableIcons, id: \.self) { icon in
                            IconPickerButton(
                                icon: icon,
                                color: selectedColor,
                                isSelected: selectedIcon == icon
                            ) {
                                selectedIcon = icon
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Delete
                if isEditing, let onDelete {
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Project")
                            }
                        }
                    } footer: {
                        Text("Tasks in this project will be moved to Inbox.")
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Project" : "New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .confirmationDialog("Delete Project", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    onDelete?()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Tasks in this project will be moved to Inbox.")
            }
        }
    }

    private func save() {
        var savedProject = project ?? Project(name: "")
        savedProject.name = name.trimmingCharacters(in: .whitespaces)
        savedProject.color = selectedColor
        savedProject.iconName = selectedIcon
        savedProject.updatedAt = Date()

        onSave(savedProject)
        dismiss()
    }
}

struct ProjectPreview: View {
    let name: String
    let color: String
    let icon: String

    private var displayColor: Color {
        Color(hex: color) ?? .indigo
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(displayColor.opacity(0.2))
                    .frame(width: 64, height: 64)

                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(displayColor)
            }

            Text(name.isEmpty ? "Project Name" : name)
                .font(.headline)
                .foregroundStyle(name.isEmpty ? .secondary : .primary)
        }
        .padding(.vertical)
    }
}

struct ColorPickerButton: View {
    let color: String
    let isSelected: Bool
    let onSelect: () -> Void

    private var displayColor: Color {
        Color(hex: color) ?? .gray
    }

    var body: some View {
        Button(action: onSelect) {
            ZStack {
                Circle()
                    .fill(displayColor)
                    .frame(width: 36, height: 36)

                if isSelected {
                    Circle()
                        .strokeBorder(.white, lineWidth: 3)
                        .frame(width: 36, height: 36)

                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct IconPickerButton: View {
    let icon: String
    let color: String
    let isSelected: Bool
    let onSelect: () -> Void

    private var displayColor: Color {
        Color(hex: color) ?? .indigo
    }

    var body: some View {
        Button(action: onSelect) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? displayColor : Color(.systemGray5))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? .white : .primary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProjectEditorView(
        project: nil,
        onSave: { _ in },
        onDelete: nil
    )
}
