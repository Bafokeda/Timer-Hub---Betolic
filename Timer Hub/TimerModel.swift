import Foundation
import SwiftUI
import AudioToolbox

enum TimerCategory: String, CaseIterable, Codable {
    case cooking = "Cooking"
    case work = "Work"
    case exercise = "Exercise"
    case other = "Other"

    var icon: String {
        switch self {
        case .cooking: return "fork.knife"
        case .work: return "laptopcomputer"
        case .exercise: return "figure.run"
        case .other: return "clock"
        }
    }

    var color: Color {
        switch self {
        case .cooking: return .orange
        case .work: return .blue
        case .exercise: return .green
        case .other: return .purple
        }
    }
}

enum TimerColor: String, CaseIterable, Codable {
    case red = "Red"
    case orange = "Orange"
    case yellow = "Yellow"
    case green = "Green"
    case blue = "Blue"
    case purple = "Purple"
    case pink = "Pink"
    case teal = "Teal"

    var color: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .teal: return .teal
        }
    }
}

enum AlarmSound: String, CaseIterable, Codable {
    case bell = "Bell"
    case chime = "Chime"
    case alert = "Alert"
    case none = "None"

    var icon: String {
        switch self {
        case .bell: return "bell"
        case .chime: return "music.note"
        case .alert: return "exclamationmark.triangle"
        case .none: return "speaker.slash"
        }
    }

    var systemSoundID: SystemSoundID {
        switch self {
        case .bell: return 1005
        case .chime: return 1013
        case .alert: return 1003
        case .none: return 0
        }
    }
}

struct TimerItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var totalSeconds: Int
    var remainingSeconds: Int
    var isRunning: Bool = false
    var isFinished: Bool = false
    var endDate: Date? = nil
    var category: TimerCategory
    var colorName: TimerColor
    var alarmSound: AlarmSound

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(remainingSeconds) / Double(totalSeconds)
    }

    var timeDisplay: String {
        let h = remainingSeconds / 3600
        let m = (remainingSeconds % 3600) / 60
        let s = remainingSeconds % 60
        if h > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }
}
