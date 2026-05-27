import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: TimerStore
    @State private var showingAddTimer = false
    @State private var editingTimer: TimerItem? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CategoryFilterView(selected: $store.selectedCategory)

                if store.filteredTimers.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(store.filteredTimers) { timer in
                                TimerCardView(timer: timer) {
                                    editingTimer = timer
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Timer Hub")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTimer = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(!store.canAddTimer)
                }
            }
            .sheet(isPresented: $showingAddTimer) {
                AddEditTimerView()
            }
            .sheet(item: $editingTimer) { timer in
                AddEditTimerView(editing: timer)
            }
            .overlay(alignment: .bottom) {
                if !store.canAddTimer {
                    Text("Maximum \(TimerStore.maxTimers) timers reached")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "timer")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("No Timers")
                .font(.title2.bold())
            Text("Tap + to add your first timer")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}

// MARK: - Category Filter

struct CategoryFilterView: View {
    @Binding var selected: TimerCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(title: "All", icon: "square.grid.2x2", isSelected: selected == nil) {
                    selected = nil
                }
                ForEach(TimerCategory.allCases, id: \.self) { cat in
                    CategoryChip(title: cat.rawValue, icon: cat.icon, isSelected: selected == cat) {
                        selected = cat
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
