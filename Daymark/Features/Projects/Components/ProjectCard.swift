import SwiftUI

public struct ProjectCard: View {
    @Environment(AppState.self) private var appState
    let project: DaymarkProject

    public init(project: DaymarkProject) {
        self.project = project
    }

    private var projectMilestones: [DaymarkMilestone] {
        appState.milestones.filter { $0.projectId == project.id }
    }

    private var completedTasksCount: Int {
        appState.completedTasksCount(for: project.id)
    }

    private var totalTasksCount: Int {
        appState.totalTasksCount(for: project.id)
    }

    private var progressRatio: Double {
        appState.projectProgressRatio(for: project.id)
    }

    private var accentColor: Color {
        if !project.colorHex.isEmpty {
            return Color(hex: project.colorHex)
        }
        return PastelTheme.forProjectName(project.name).fg
    }

    private var isCompleted: Bool {
        totalTasksCount > 0 && completedTasksCount == totalTasksCount
    }

    private var remainingTasks: Int {
        max(0, totalTasksCount - completedTasksCount)
    }

    public var body: some View {
        HStack(spacing: DMSpacing.sm + 2) {
            // Workspace Squircle Icon
            DaymarkSquircleIcon(
                iconName: project.iconName,
                backgroundColor: accentColor.opacity(0.12),
                iconColor: accentColor,
                size: 36,
                cornerRadius: 10,
                iconSize: 16
            )

            // Name & Description
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(project.name)
                        .font(.system(size: 15.5, weight: .semibold))
                        .foregroundColor(Color.dmTextPrimary)

                    if project.status != .active {
                        Text(project.status.displayName)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.dmTextTertiary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background(Color.dmSecondaryCard)
                            .clipShape(Capsule())
                    }
                }

                if let desc = project.description, !desc.isEmpty {
                    Text(desc)
                        .font(.system(size: 12.5))
                        .foregroundColor(Color.dmTextSecondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            // Right Indicator: Things 3 Progress Pie or Completed Checkmark + Count
            HStack(spacing: 8) {
                if isCompleted {
                    HStack(spacing: 3.5) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                        Text("Done")
                            .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(Color.dmSuccess)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.dmMintBg)
                    .clipShape(Capsule())
                } else if totalTasksCount > 0 {
                    HStack(spacing: 5) {
                        // Things 3 Style Circular Progress Pie
                        ZStack {
                            Circle()
                                .stroke(Color.dmBorder.opacity(0.8), lineWidth: 1.8)
                                .frame(width: 16, height: 16)

                            Circle()
                                .trim(from: 0, to: CGFloat(progressRatio))
                                .stroke(accentColor, style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .frame(width: 16, height: 16)
                        }

                        Text("\(remainingTasks)")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.dmTextSecondary)
                    }
                } else {
                    Text("0 tasks")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.dmTextTertiary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.dmTextTertiary.opacity(0.55))
            }
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
