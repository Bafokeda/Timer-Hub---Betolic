import Foundation
import Combine
import UserNotifications
import AudioToolbox

class TimerStore: NSObject, ObservableObject {
    static let maxTimers = 5

    @Published var timers: [TimerItem] = []
    @Published var selectedCategory: TimerCategory? = nil

    private var ticker: AnyCancellable?

    var filteredTimers: [TimerItem] {
        guard let cat = selectedCategory else { return timers }
        return timers.filter { $0.category == cat }
    }

    var canAddTimer: Bool { timers.count < Self.maxTimers }

    override init() {
        super.init()
        loadTimers()
        startTicker()
        setupNotifications()
    }

    func add(_ item: TimerItem) {
        guard canAddTimer else { return }
        timers.append(item)
        save()
    }

    func update(_ item: TimerItem) {
        guard let i = timers.firstIndex(where: { $0.id == item.id }) else { return }
        timers[i] = item
        save()
    }

    func delete(id: UUID) {
        timers.removeAll { $0.id == id }
        save()
    }

    func duplicate(_ item: TimerItem) {
        guard canAddTimer else { return }
        var copy = item
        copy.id = UUID()
        copy.name = item.name + " Copy"
        copy.isRunning = false
        copy.isFinished = false
        copy.endDate = nil
        copy.remainingSeconds = item.totalSeconds
        timers.append(copy)
        save()
    }

    func toggle(id: UUID) {
        guard let i = timers.firstIndex(where: { $0.id == id }) else { return }
        if timers[i].isFinished {
            timers[i].remainingSeconds = timers[i].totalSeconds
            timers[i].isFinished = false
            timers[i].endDate = nil
        }
        timers[i].isRunning.toggle()
        if timers[i].isRunning {
            timers[i].endDate = Date().addingTimeInterval(Double(timers[i].remainingSeconds))
        } else {
            timers[i].endDate = nil
        }
        save()
    }

    func reset(id: UUID) {
        guard let i = timers.firstIndex(where: { $0.id == id }) else { return }
        timers[i].isRunning = false
        timers[i].isFinished = false
        timers[i].endDate = nil
        timers[i].remainingSeconds = timers[i].totalSeconds
        cancelNotification(id: timers[i].id)
        save()
    }

    func handleBackground() {
        let center = UNUserNotificationCenter.current()
        for timer in timers where timer.isRunning {
            guard let endDate = timer.endDate else { continue }
            let remaining = endDate.timeIntervalSince(Date())
            guard remaining > 1 else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Timer Finished"
            content.body = "\(timer.name) is done!"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: remaining, repeats: false)
            let request = UNNotificationRequest(
                identifier: "bg_\(timer.id.uuidString)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    func handleForeground() {
        let now = Date()
        for i in timers.indices {
            guard timers[i].isRunning, let endDate = timers[i].endDate else { continue }
            let remaining = Int(endDate.timeIntervalSince(now))
            if remaining <= 0 {
                timers[i].remainingSeconds = 0
                timers[i].isRunning = false
                timers[i].isFinished = true
                timers[i].endDate = nil
            } else {
                timers[i].remainingSeconds = remaining
            }
        }
        let ids = timers.map { "bg_\($0.id.uuidString)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        save()
    }

    private func startTicker() {
        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        var changed = false
        for i in timers.indices {
            guard timers[i].isRunning, timers[i].remainingSeconds > 0 else { continue }
            timers[i].remainingSeconds -= 1
            changed = true
            if timers[i].remainingSeconds == 0 {
                timers[i].isRunning = false
                timers[i].isFinished = true
                timers[i].endDate = nil
                playAlarm(for: timers[i])
                sendForegroundNotification(for: timers[i])
            }
        }
        if changed { save() }
    }

    private func playAlarm(for item: TimerItem) {
        guard item.alarmSound != .none else { return }
        AudioServicesPlaySystemSound(item.alarmSound.systemSoundID)
    }

    private func sendForegroundNotification(for item: TimerItem) {
        let content = UNMutableNotificationContent()
        content.title = "Timer Finished"
        content.body = "\(item.name) is done!"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotification(id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [id.uuidString, "bg_\(id.uuidString)"]
        )
    }

    private func setupNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(timers) {
            UserDefaults.standard.set(data, forKey: "timers_v1")
        }
    }

    private func loadTimers() {
        guard
            let data = UserDefaults.standard.data(forKey: "timers_v1"),
            let items = try? JSONDecoder().decode([TimerItem].self, from: data)
        else { return }
        timers = items.map {
            var t = $0
            t.isRunning = false
            return t
        }
    }
}

extension TimerStore: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
