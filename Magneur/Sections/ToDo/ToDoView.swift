import SwiftUI

struct ToDoView: View {
    @State private var selectedTab: ToDoTab = .today
    @State private var showAddTask = false
    @State private var showSearch = false

    enum ToDoTab: String, CaseIterable {
        case today = "Today"
        case upcoming = "Upcoming"
        case projects = "Projects"
        case habits = "Habits"

        var icon: String {
            switch self {
            case .today: return "sun.max.fill"
            case .upcoming: return "calendar"
            case .projects: return "folder.fill"
            case .habits: return "flame.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: AppSection.todo.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom tab bar
                    HStack(spacing: 0) {
                        ForEach(ToDoTab.allCases, id: \.self) { tab in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = tab
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 18))
                                    Text(tab.rawValue)
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                            }
                        }
                    }
                    .background(.ultraThinMaterial.opacity(0.3))

                    // Tab content
                    TabView(selection: $selectedTab) {
                        TodayView()
                            .tag(ToDoTab.today)

                        UpcomingView()
                            .tag(ToDoTab.upcoming)

                        ProjectsListView()
                            .tag(ToDoTab.projects)

                        HabitsListView()
                            .tag(ToDoTab.habits)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("To-Do")
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 12) {
                        Button {
                            showSearch = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.white)
                        }

                        Button {
                            showAddTask = true
                        } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddTask) {
                TaskEditorSheet(
                    isPresented: $showAddTask,
                    projectId: nil,
                    onSave: { task in
                        ToDoStore.shared.saveTask(task)
                    }
                )
            }
            .sheet(isPresented: $showSearch) {
                NavigationStack {
                    ZStack {
                        LinearGradient(
                            colors: AppSection.todo.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()

                        TaskSearchView()
                    }
                    .navigationTitle("Search")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                showSearch = false
                            }
                            .foregroundStyle(.white)
                        }
                    }
                    .toolbarBackground(.hidden, for: .navigationBar)
                }
            }
        }
    }
}

#Preview {
    ToDoView()
}
