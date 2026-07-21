import SwiftUI
import SwiftData

struct EntityCreationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedType: EntityType = .person
    @State private var notes = ""
    @State private var selectedEntity: Entity?

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Photo Upload Container
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 84, height: 84)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.blue.opacity(0.4), .purple.opacity(0.2)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                style: StrokeStyle(lineWidth: 1.5, dash: [4])
                                            )
                                    )

                                Image(systemName: "camera.fill")
                                    .font(.system(size: 26))
                                    .foregroundStyle(Color(red: 0.1, green: 0.45, blue: 0.95))
                            }

                            Text("ADD PHOTO")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)

                        // ENTITY NAME
                        VStack(alignment: .leading, spacing: 6) {
                            Text("ENTITY NAME")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)

                            HStack {
                                TextField("Searching for matches...", text: $name)
                                    .font(.subheadline)

                                Spacer()

                                ProgressView()
                                    .scaleEffect(0.8)
                                    .opacity(name.isEmpty ? 0 : 0.6)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                        }

                        // CATEGORY
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CATEGORY")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(EntityType.allCases) { type in
                                        let isSelected = selectedType == type
                                        Button {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedType = type
                                            }
                                        } label: {
                                            HStack(spacing: 6) {
                                                Circle()
                                                    .fill(type.color)
                                                    .frame(width: 7, height: 7)
                                                Text(type.rawValue)
                                                    .font(.subheadline)
                                                    .fontWeight(isSelected ? .semibold : .medium)
                                            }
                                            .glassPill(isSelected: isSelected, activeColor: type.color)
                                            .foregroundStyle(isSelected ? .white : .primary)
                                        }
                                    }
                                }
                            }
                        }

                        // NOTES & CONTEXT
                        VStack(alignment: .leading, spacing: 6) {
                            Text("NOTES & CONTEXT")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)

                            ZStack(alignment: .topLeading) {
                                if notes.isEmpty {
                                    Text("Define how this entity interlinks with your existing network...")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.tertiary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                        .allowsHitTesting(false)
                                }

                                TextEditor(text: $notes)
                                    .font(.subheadline)
                                    .scrollContentBackground(.hidden)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .frame(minHeight: 110)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                        }

                        // AUTOMATIC SUGGESTIONS
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Automatic Suggestions")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)

                                Spacer()

                                Image(systemName: "sparkles")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color(red: 0.1, green: 0.45, blue: 0.95))
                            }

                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Capsule()
                                        .fill(Color.secondary.opacity(0.2))
                                        .frame(width: 50, height: 10)
                                    Capsule()
                                        .fill(Color.secondary.opacity(0.15))
                                        .frame(width: 80, height: 8)
                                }
                                .glassCard(cornerRadius: 12, padding: 12)

                                VStack(alignment: .leading, spacing: 6) {
                                    Capsule()
                                        .fill(Color.secondary.opacity(0.2))
                                        .frame(width: 60, height: 10)
                                    Capsule()
                                        .fill(Color.secondary.opacity(0.15))
                                        .frame(width: 70, height: 8)
                                }
                                .glassCard(cornerRadius: 12, padding: 12)
                            }
                        }
                        .padding(.top, 6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("New Entity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .fontWeight(.medium)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntity()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveEntity() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let entity = Entity(
            name: trimmedName,
            type: selectedType,
            notes: notes
        )
        modelContext.insert(entity)

        try? modelContext.save()
        dismiss()
    }
}
