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
            HStack(alignment: .top, spacing: DMSpacing.mdSm) {
                DaymarkSquircleIcon(
                    iconName: project.iconName,
                    backgroundColor: theme.fg.opacity(0.16),
                    iconColor: theme.fg,
                    size: 44,
                    cornerRadius: 14,
                    iconSize: 20
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(project.name)
                        .font(.dmTitle2)
                        .foregroundColor(Color.dmTextPrimary)

                    if let desc = project.description, !desc.isEmpty {
                        Text(desc)
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextSecondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                HStack(spacing: DMSpacing.xs) {
                    if project.status != .active {
                        Text(project.status.displayName)
                            .font(.dmCaptionBold)
                            .foregroundColor(Color.dmTextSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.7))
                            .clipShape(Capsule())
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.dmTextTertiary)
                }
            }

            // Refined Progress Bar with percentage (Concept 2 style)
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.8))
                            .frame(height: 6)

                        Capsule()
                            .fill(theme.fg)
                            .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(progressRatio))), height: 6)
                    }
                }
                .frame(height: 6)

                // Meta Row with tasks done, milestones, and avatar stack (Concept 2 style)
                HStack(alignment: .center) {
                    Text("\(completedTasksCount) of \(totalTasksCount) tasks done")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextSecondary)

                    if !projectMilestones.isEmpty {
                        Text("•")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextTertiary)

                        Text("\(completedMilestonesCount)/\(projectMilestones.count) milestones")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextTertiary)
                    }

                    Spacer()

                    // Collaborator avatar stack bubbles (Concept 2 style)
                    DaymarkAvatarStack(size: 22, count: 4)
                }
                .padding(.top, 2)
            }
        }
        .padding(DMSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous)
                .fill(theme.bg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous)
                .stroke(theme.fg.opacity(0.20), lineWidth: 0.8)
        )
        .shadow(color: theme.fg.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

// Color hex parser extension
public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 59, 130, 246)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
