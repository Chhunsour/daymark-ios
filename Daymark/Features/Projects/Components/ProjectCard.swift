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

    private var accentColor: Color {
        if !project.colorHex.isEmpty {
            return Color(hex: project.colorHex)
        }
        return PastelTheme.forProjectName(project.name).fg
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DMSpacing.sm + 3) {
            // Header Row: Squircle Icon + Title/Description + Progress Ring + Chevron
            HStack(spacing: DMSpacing.sm) {
                // Workspace Squircle Icon with subtle tinted background
                DaymarkSquircleIcon(
                    iconName: project.iconName,
                    backgroundColor: accentColor.opacity(0.12),
                    iconColor: accentColor,
                    size: 38,
                    cornerRadius: 11,
                    iconSize: 18
                )

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(project.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.dmTextPrimary)

                        if project.status != .active {
                            Text(project.status.displayName)
                                .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.dmTextTertiary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.dmSecondaryCard)
                                .clipShape(Capsule())
                        }
                    }

                    if let desc = project.description, !desc.isEmpty {
                        Text(desc)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color.dmTextSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 4)

                // Compact Circular Progress Ring / Completion Badge
                circularProgressBadge
                    .padding(.trailing, 2)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.dmTextTertiary.opacity(0.7))
            }

            // Divider / Micro Progress Line
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.dmBorder.opacity(0.45))
                        .frame(height: 3)

                    Capsule()
                        .fill(accentColor)
                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(progressRatio))), height: 3)
                        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: progressRatio)
                }
            }
            .frame(height: 3)
            .padding(.top, 1)

            // Metadata Row
            HStack(alignment: .center) {
                if totalTasksCount == 0 {
                    Text("No tasks yet")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.dmTextTertiary)
                } else if completedTasksCount == totalTasksCount {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color.dmSuccess)
                        Text("All \(totalTasksCount) tasks done")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.dmSuccess)
                    }
                } else {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 5, height: 5)
                        Text("\(totalTasksCount - completedTasksCount) tasks remaining")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color.dmTextSecondary)
                    }
                }

                if !projectMilestones.isEmpty {
                    Text("•")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.dmTextTertiary)

                    Text("\(completedMilestonesCount)/\(projectMilestones.count) milestones")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color.dmTextTertiary)
                }

                Spacer()

                Text("\(completedTasksCount)/\(totalTasksCount)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.dmTextTertiary)
            }
        }
        .padding(DMSpacing.md)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.dmBorder.opacity(0.7), lineWidth: 0.6)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1.5)
    }

    private var circularProgressBadge: some View {
        ZStack {
            if totalTasksCount > 0 && completedTasksCount == totalTasksCount {
                Circle()
                    .fill(Color.dmMintBg)
                    .frame(width: 28, height: 28)
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.dmSuccess)
            } else {
                Circle()
                    .stroke(Color.dmBorder.opacity(0.5), lineWidth: 2.2)
                    .frame(width: 28, height: 28)

                Circle()
                    .trim(from: 0, to: CGFloat(progressRatio))
                    .stroke(accentColor, style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 28, height: 28)

                Text("\(Int(progressRatio * 100))%")
                    .font(.system(size: 8.5, weight: .bold, design: .rounded))
                    .foregroundColor(Color.dmTextPrimary)
            }
        }
    }
}
