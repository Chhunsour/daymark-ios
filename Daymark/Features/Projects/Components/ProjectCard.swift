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

    public var body: some View {
        VStack(alignment: .leading, spacing: DMSpacing.sm) {
            // Header with icon, name, and status badge
            HStack(spacing: DMSpacing.sm) {
                Image(systemName: project.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: project.colorHex))
                    .frame(width: 32, height: 32)
                    .background(Color(hex: project.colorHex).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: DMRadius.sm))

                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name)
                        .font(.dmBodyBold)
                        .foregroundColor(Color.dmTextPrimary)

                    if let desc = project.description, !desc.isEmpty {
                        Text(desc)
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                if project.status != .active {
                    DaymarkBadge(title: project.status.displayName, variant: .neutral)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.dmTextSecondary.opacity(0.5))
            }

            // Real progress bar
            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.dmBorder.opacity(0.5))
                            .frame(height: 5)

                        Capsule()
                            .fill(Color(hex: project.colorHex))
                            .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(progressRatio))), height: 5)
                    }
                }
                .frame(height: 5)

                HStack {
                    Text("\(completedTasksCount)/\(totalTasksCount) tasks done")
                        .font(.dmCaption)
                        .foregroundColor(Color.dmTextSecondary)

                    Spacer()

                    if !projectMilestones.isEmpty {
                        Text("\(completedMilestonesCount)/\(projectMilestones.count) milestones")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextSecondary)
                    }
                }
            }
            .padding(.top, DMSpacing.xxs)
        }
        .padding(DMSpacing.md)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.md))
        .overlay(RoundedRectangle(cornerRadius: DMRadius.md).stroke(Color.dmBorder.opacity(0.6), lineWidth: 1))
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
