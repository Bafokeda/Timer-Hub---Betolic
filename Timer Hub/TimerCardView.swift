import SwiftUI

struct TimerCardView: View {
    let timer: TimerItem
    let onEdit: () -> Void
    @EnvironmentObject var store: TimerStore

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(timer.colorName.color.opacity(0.15))
                    Rectangle()
                        .fill(timer.colorName.color)
                        .frame(width: geo.size.width * timer.progress)
                        .animation(.linear(duration: 1), value: timer.progress)
                }
            }
            .frame(height: 4)

            VStack(spacing: 12) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: timer.category.icon)
                            .foregroundStyle(timer.colorName.color)
                        Text(timer.name)
                            .font(.headline)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text(timer.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(timer.colorName.color.opacity(0.15))
                        .foregroundStyle(timer.colorName.color)
                        .clipShape(Capsule())
                }

                HStack {
                    Text(timer.timeDisplay)
                        .font(.system(size: 48, weight: .thin, design: .monospaced))
                        .foregroundStyle(timer.isFinished ? .green : .primary)
                        .minimumScaleFactor(0.6)
                    if timer.isFinished {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 16) {
                    Button {
                        store.reset(id: timer.id)
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .frame(width: 44, height: 44)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    Button {
                        store.toggle(id: timer.id)
                    } label: {
                        Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(timer.isRunning ? Color.orange : timer.colorName.color)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Menu {
                        Button {
                            onEdit()
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button {
                            store.duplicate(timer)
                        } label: {
                            Label("Duplicate", systemImage: "doc.on.doc")
                        }
                        Divider()
                        Button(role: .destructive) {
                            store.delete(id: timer.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .frame(width: 44, height: 44)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}
