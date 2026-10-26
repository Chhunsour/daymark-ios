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

    private var completedMilestonesCount: Int {
        projectMilestones.filter { $0.isCompleted }.count
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

    private var theme: PastelTheme {
        PastelTheme.forProjectName(project.name)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DMSpacing.mdSm) {
            // Header with icon squircle, title, description, and status badge
            HStack(alignment: .top, spacing: DMSpacing.sm) {
                DaymarkSquircleIcon(
                    iconName: project.iconName,
                    backgroundColor: theme.fg.opacity(0.14),
                    iconColor: theme.fg,
                    size: 42,
                    cornerRadius: 13,
                    iconSize: 19
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.dmTextPrimary)

                    if let desc = project.description, !desc.isEmpty {
                        Text(desc)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.dmTextSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                HStack(spacing: DMSpacing.xs) {
                    if project.status != .active {
                        Text(project.status.displayName)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(Color.dmTextSecondary)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2.5)
                            .background(Color.dmCard)
                            .clipShape(Capsule())
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.dmTextTertiary)
                }
            }

            // Refined Progress Bar with percentage (Concept 2 style)
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.85))
                            .frame(height: 5)

                        Capsule()
                            .fill(theme.fg)
                            .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(progressRatio))), height: 5)
                    }
                }
                .frame(height: 5)

                // Meta Row with tasks done and milestones
                HStack(alignment: .center) {
                    Text("\(completedTasksCount) of \(totalTasksCount) tasks done")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Color.dmTextSecondary)

                    if !projectMilestones.isEmpty {
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(Color.dmTextTertiary)

                        Text("\(completedMilestonesCount)/\(projectMilestones.count) milestones")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(Color.dmTextTertiary)
                    }

                    Spacer()

                    Text("\(Int(progressRatio * 100))%")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(theme.fg)
                }
                .padding(.top, 1)
            }
        }
        .padding(DMSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(theme.bg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(theme.fg.opacity(0.22), lineWidth: 0.8)
        )
        .shadow(color: theme.fg.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}
