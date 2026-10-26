import SwiftUI

public struct DailyPrioritiesSection: View {
    @Environment(AppState.self) private var appState
    var onSelectTask: ((DaymarkTask) -> Void)?

    public init(onSelectTask: ((DaymarkTask) -> Void)? = nil) {
        self.onSelectTask = onSelectTask
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DMSpacing.sm) {
            HStack {
                Text("DAILY PRIORITIES")
                    .font(.dmSectionHeader)
                    .foregroundColor(Color.dmTextSecondary)
                    .tracking(0.8)

                Spacer()

                Text("\(appState.todayPriorities.count)/5")
                    .font(.dmCaption)
                    .foregroundColor(Color.dmTextSecondary)
            }
            .padding(.horizontal, DMSpacing.md)

            if appState.todayPriorities.isEmpty {
                VStack(spacing: DMSpacing.xs) {
                    Text("No daily priorities selected yet")
                        .font(.dmBody)
                        .foregroundColor(Color.dmTextSecondary)
                    Text("Select up to 5 critical outcomes that genuinely matter today.")
                        .font(.dmCaption)
                        .foregroundColor(Color.dmTextSecondary.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(DMSpacing.md)
                .background(Color.dmCard.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: DMRadius.md))
                .overlay(RoundedRectangle(cornerRadius: DMRadius.md).stroke(Color.dmBorder.opacity(0.5), lineWidth: 1))
                .padding(.horizontal, DMSpacing.md)
            } else {
                VStack(spacing: DMSpacing.xs) {
                    ForEach(Array(appState.todayPriorities.enumerated()), id: \.element.id) { index, task in
                        priorityRow(task: task, rank: index + 1)
                    }
                }
                .padding(.horizontal, DMSpacing.md)
            }
        }
    }

    private func priorityRow(task: DaymarkTask, rank: Int) -> some View {
        let projectName = appState.projects.first(where: { $0.id == task.projectId })?.name

        return HStack(spacing: DMSpacing.sm) {
            // Priority number badge
            Text("\(rank)")
                .font(.dmCaptionBold)
                .foregroundColor(Color.dmAccent)
                .frame(width: 20, height: 20)
                .background(Color.dmAccent.opacity(0.15))
                .clipShape(Circle())

            // Title and metadata
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.dmBodyBold)
                    .foregroundColor(Color.dmTextPrimary)
                    .lineLimit(1)

                HStack(spacing: DMSpacing.xs) {
                    if let project = projectName {
                        Text(project)
                            .font(.dmCaption)
                            .foregroundColor(Color.dmHighlight)
                    }
                    if let due = task.dueDate {
                        Text("• Due \(DateFormatter.localizedString(from: due, dateStyle: .none, timeStyle: .short))")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmWarning)
                    }
                }
            }

            Spacer()

            // Quick complete toggle
            Button {
                Task { try? await appState.completeTask(task) }
            } label: {
                Image(systemName: "circle")
                    .font(.system(size: 20))
                    .foregroundColor(Color.dmBorder)
            }
            .buttonStyle(.plain)
        }
        .padding(DMSpacing.sm + 2)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.sm, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DMRadius.sm, style: .continuous)
                .stroke(Color.dmBorder.opacity(0.5), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectTask?(task)
        }
    }
}
