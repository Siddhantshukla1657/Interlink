import SwiftUI
import SwiftData

struct EntityDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var entity: Entity

    @State private var isEditingNotes = false

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {

                    // Header Profile Banner
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(entity.type.color.opacity(0.2))
                                .frame(width: 80, height: 80)

                            if entity.name == "Elena Rodriguez" || entity.type == .person {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(entity.type.color)
                            } else {
                                Image(systemName: entity.type.icon)
                                    .font(.system(size: 36, weight: .semibold))
                                    .foregroundStyle(entity.type.color)
                            }
                        }
                        .shadow(color: entity.type.color.opacity(0.25), radius: 10, x: 0, y: 5)

                        Text(entity.name)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.primary)

                        HStack(spacing: 5) {
                            Circle()
                                .fill(entity.type.color)
                                .frame(width: 6, height: 6)

                            Text(entity.type.rawValue.uppercased())
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    .padding(.top, 10)

                    // NOTES Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("NOTES")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)

                            Spacer()

                            Button {
                                isEditingNotes.toggle()
                            } label: {
                                Text(isEditingNotes ? "Done" : "Edit")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color(red: 0.1, green: 0.45, blue: 0.95))
                            }
                        }

                        if isEditingNotes {
                            TextEditor(text: $entity.notes)
                                .font(.subheadline)
                                .frame(minHeight: 100)
                                .scrollContentBackground(.hidden)
                        } else {
                            Text(entity.notes.isEmpty ? "No notes added yet." : entity.notes)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.primary.opacity(0.85))
                                .lineSpacing(4)
                        }
                    }
                    .glassCard(cornerRadius: 18, padding: 16)
                    .padding(.horizontal, 20)

                    // CONNECTIONS SECTION
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Connections")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.primary)

                            Spacer()

                            Button {
                                // Add Connection action
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 11, weight: .bold))
                                    Text("Add")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color(red: 0.1, green: 0.45, blue: 0.95)))
                                .foregroundStyle(.white)
                            }
                        }

                        // WORKS ON
                        VStack(alignment: .leading, spacing: 8) {
                            Text("WORKS ON")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)

                            VStack(spacing: 8) {
                                connectionRow(
                                    icon: "rocket.fill",
                                    iconColor: .orange,
                                    title: "Project Aurora",
                                    subtitle: "CRITICAL PRIORITY",
                                    subtitleColor: .orange
                                )

                                connectionRow(
                                    icon: "point.3.connected.trianglepath.dotted",
                                    iconColor: .purple,
                                    title: "Mesh Governance",
                                    subtitle: "ONGOING",
                                    subtitleColor: .purple
                                )
                            }
                        }

                        // KNOWS
                        VStack(alignment: .leading, spacing: 8) {
                            Text("KNOWS")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)

                            VStack(spacing: 8) {
                                connectionRow(
                                    icon: "person.crop.circle.fill",
                                    iconColor: .blue,
                                    title: "Marcus Chen",
                                    subtitle: "PRODUCT DESIGNER",
                                    subtitleColor: .secondary
                                )

                                connectionRow(
                                    icon: "person.crop.circle.fill",
                                    iconColor: .cyan,
                                    title: "Sarah Jenkins",
                                    subtitle: "CHIEF ARCHITECT",
                                    subtitleColor: .secondary
                                )
                            }
                        }

                        // BASED IN
                        VStack(alignment: .leading, spacing: 8) {
                            Text("BASED IN")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)

                            mapConnectionCard(
                                title: "San Francisco HQ",
                                subtitle: "Pacific Heights Studio"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                        Text("Back")
                    }
                    .foregroundStyle(Color(red: 0.1, green: 0.45, blue: 0.95))
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button {} label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(Color(red: 0.1, green: 0.45, blue: 0.95))
                    }
                    Button {} label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color(red: 0.1, green: 0.45, blue: 0.95))
                    }
                }
            }
        }
    }

    private func connectionRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        subtitleColor: Color
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.18))
                    .frame(width: 38, height: 38)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)

                Text(subtitle)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(subtitleColor)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.tertiary)
        }
        .glassCard(cornerRadius: 14, padding: 10)
    }

    private func mapConnectionCard(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                // Map visual placeholder backdrop
                LinearGradient(
                    colors: [Color.teal.opacity(0.4), Color.blue.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 100)
                .overlay(
                    MapGridPattern()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )

                // Pin marker
                VStack(spacing: 2) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.red)
                        .shadow(radius: 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(12)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .mask(RoundedRectangle(cornerRadius: 10))
                )
                .padding(8)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
    }
}

struct MapGridPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 20
        for x in stride(from: 0, to: rect.width, by: step) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        for y in stride(from: 0, to: rect.height, by: step) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        return path
    }
}
