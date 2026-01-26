import SwiftUI

struct ProjectsListView: View {
    @State private var projects: [Project] = []
    @State private var showAddProject = false
    @State private var selectedProject: Project?
    @State private var showInbox = false

    private var inboxCount: Int {
        ToDoStore.shared.taskCount(forProject: nil)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Inbox card
                InboxCard(taskCount: inboxCount) {
                    showInbox = true
                }
                .padding(.horizontal)

                // Projects header with add button
                HStack {
                    Text("Projects")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Spacer()

                    Button {
                        showAddProject = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("New")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Projects grid
                if projects.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 48))
                            .foregroundStyle(.white.opacity(0.5))

                        Text("No projects yet")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.7))

                        Text("Create projects to organize your tasks")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.vertical, 48)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(projects) { project in
                            ProjectCard(
                                project: project,
                                taskCount: ToDoStore.shared.taskCount(forProject: project.id)
                            ) {
                                selectedProject = project
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            loadProjects()
        }
        .refreshable {
            loadProjects()
        }
        .sheet(isPresented: $showAddProject) {
            ProjectEditorView(
                project: nil,
                onSave: { project in
                    ToDoStore.shared.saveProject(project)
                    loadProjects()
                },
                onDelete: nil
            )
        }
        .sheet(isPresented: $showInbox) {
            NavigationStack {
                ProjectDetailView(
                    project: nil,  // nil = Inbox
                    onProjectUpdated: {}
                )
            }
        }
        .sheet(item: $selectedProject) { project in
            NavigationStack {
                ProjectDetailView(
                    project: project,
                    onProjectUpdated: { loadProjects() }
                )
            }
        }
    }

    private func loadProjects() {
        projects = ToDoStore.shared.fetchAllProjects()
    }
}

struct InboxCard: View {
    let taskCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: "tray.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                }

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text("Inbox")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("Tasks without a project")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                // Count
                if taskCount > 0 {
                    Text("\(taskCount)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.3))
                        )
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ProjectCard: View {
    let project: Project
    let taskCount: Int
    let onTap: () -> Void

    private var projectColor: Color {
        Color(hex: project.color) ?? .indigo
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(projectColor.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: project.iconName)
                        .font(.system(size: 20))
                        .foregroundStyle(projectColor)
                }

                // Name
                Text(project.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Spacer()

                // Task count
                HStack {
                    Text("\(taskCount) tasks")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [projectColor.opacity(0.3), projectColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .strokeBorder(projectColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.blue, .indigo],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ProjectsListView()
    }
}
