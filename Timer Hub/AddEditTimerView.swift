import SwiftUI

struct AddEditTimerView: View {
    @EnvironmentObject var store: TimerStore
    @Environment(\.dismiss) private var dismiss

    var editing: TimerItem? = nil

    @State private var name: String = ""
    @State private var hours: Int = 0
    @State private var minutes: Int = 5
    @State private var seconds: Int = 0
    @State private var category: TimerCategory = .other
    @State private var colorName: TimerColor = .blue
    @State private var alarmSound: AlarmSound = .bell

    private var isEditing: Bool { editing != nil }
    private var totalSeconds: Int { hours * 3600 + minutes * 60 + seconds }
    private var isValid: Bool { totalSeconds > 0 && !name.trimmingCharacters(in: .whitespaces).isEmpty }
 
    var body: some View {
        NavigationStack {
            Form {
                Section("Timer Info") {
                    TextField("Timer Name", text: $name)
                }

                Section("Duration") {
                    HStack(spacing: 0) {
                        Picker("Hours", selection: $hours) {
                            ForEach(0..<24, id: \.self) { Text("\($0)h").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)

                        Picker("Minutes", selection: $minutes) {
                            ForEach(0..<60, id: \.self) { Text("\($0)m").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)

                        Picker("Seconds", selection: $seconds) {
                            ForEach(0..<60, id: \.self) { Text("\($0)s").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 120)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(TimerCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(TimerColor.allCases, id: \.self) { c in
                            Circle()
                                .fill(c.color)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    if colorName == c {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .font(.callout.bold())
                                    }
                                }
                                .onTapGesture { colorName = c }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Alarm Sound") {
                    Picker("Sound", selection: $alarmSound) {
                        ForEach(AlarmSound.allCases, id: \.self) { s in
                            Label(s.rawValue, systemImage: s.icon).tag(s)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Timer" : "New Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Save" : "Add") {
                        commit()
                    }
                    .bold()
                    .disabled(!isValid)
                }
            }
            .onAppear { prefill() }
        }
    }

    private func prefill() {
        guard let t = editing else { return }
        name = t.name
        hours = t.totalSeconds / 3600
        minutes = (t.totalSeconds % 3600) / 60
        seconds = t.totalSeconds % 60
        category = t.category
        colorName = t.colorName
        alarmSound = t.alarmSound
    }

    private func commit() {
        if var t = editing {
            t.name = name
            t.totalSeconds = totalSeconds
            t.remainingSeconds = totalSeconds
            t.isRunning = false
            t.isFinished = false
            t.category = category
            t.colorName = colorName
            t.alarmSound = alarmSound
            store.update(t)
        } else {
            let t = TimerItem(
                name: name,
                totalSeconds: totalSeconds,
                remainingSeconds: totalSeconds,
                category: category,
                colorName: colorName,
                alarmSound: alarmSound
            )
            store.add(t)
        }
        dismiss()
    }
}
