import SwiftUI
import SwiftData

struct AddConnectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let sourceEntity: Entity
    var prefilledTargetName: String = ""

    @State private var selectedPreset: RelationshipPreset = RelationshipPreset.defaultPresets.first!
    @State private var isCustomRelationship = false
    @State private var customForward = ""
    @State private var customReverse = ""

    @State private var targetName = ""
    @State private var targetSelectedEntity: Entity? = nil
    @State private var targetType: EntityType = .person

    @State private var errorMessage: String? = nil
    @State private var duplicateWarning: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // SOURCE ENTITY ROW (READ ONLY)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("FROM (SOURCE)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)

                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(sourceEntity.type.color.opacity(0.2))
                                        .frame(width: 36, height: 36)
                                    if let data = sourceEntity.imageData, let img = UIImage(data: data) {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 36, height: 36)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: sourceEntity.type.icon)
                                            .foregroundStyle(sourceEntity.type.color)
                                    }
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(sourceEntity.name)
                                        .font(.system(size: 15, weight: .semibold))
                                    Text(sourceEntity.type.rawValue.uppercased())
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Color.secondary)
                                }
                                Spacer()
                            }
                            .glassCard(cornerRadius: 14, padding: 10)
                        }

                        // RELATIONSHIP TYPE SELECTION
                        VStack(alignment: .leading, spacing: 10) {
                            Text("RELATIONSHIP TYPE")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(RelationshipPreset.defaultPresets) { preset in
                                        let isSelected = !isCustomRelationship && selectedPreset.forward == preset.forward
                                        Button {
                                            withAnimation {
                                                isCustomRelationship = false
                                                selectedPreset = preset
                                            }
                                        } label: {
                                            Text(preset.forward)
                                                .font(.subheadline)
                                                .fontWeight(isSelected ? .semibold : .medium)
                                                .glassPill(isSelected: isSelected, activeColor: Color(red: 0.1, green: 0.45, blue: 0.95))
                                                .foregroundStyle(isSelected ? .white : .primary)
                                        }
                                    }

                                    Button {
                                        withAnimation {
                                            isCustomRelationship = true
                                        }
                                    } label: {
                                        Text("CUSTOM...")
                                            .font(.subheadline)
                                            .fontWeight(isCustomRelationship ? .semibold : .medium)
                                            .glassPill(isSelected: isCustomRelationship, activeColor: .purple)
                                            .foregroundStyle(isCustomRelationship ? .white : .primary)
                                    }
                                }
                            }

                            if isCustomRelationship {
                                VStack(alignment: .leading, spacing: 10) {
                                    TextField("Forward phrase (e.g. ADVISES)", text: $customForward)
                                        .textFieldStyle(.plain)
                                        .padding(10)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))

                                    TextField("Reverse phrase (e.g. ADVISED BY)", text: $customReverse)
                                        .textFieldStyle(.plain)
                                        .padding(10)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .padding(.top, 4)
                            } else {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.secondary)
                                    Text("Reverse phrase: \"\(selectedPreset.reverse)\"")
                                        .font(.caption)
                                        .foregroundStyle(Color.secondary)
                                }
                                .padding(.horizontal, 4)
                            }
                        }

                        // TARGET ENTITY
                        VStack(alignment: .leading, spacing: 6) {
                            Text("TO (TARGET ENTITY)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)

                            NameFieldWithMatches(text: $targetName, selectedEntity: $targetSelectedEntity, excludeEntityID: sourceEntity.id)

                            if targetSelectedEntity == nil && !targetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("NEW ENTITY CATEGORY")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Color.secondary)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 6) {
                                            ForEach(EntityType.allCases) { type in
                                                let isSel = targetType == type
                                                Button {
                                                    targetType = type
                                                } label: {
                                                    Text(type.rawValue)
                                                        .font(.caption)
                                                        .fontWeight(isSel ? .bold : .regular)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 4)
                                                        .background(isSel ? type.color : Color.secondary.opacity(0.15))
                                                        .foregroundStyle(isSel ? .white : .primary)
                                                        .clipShape(Capsule())
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.red)
                                .padding(.horizontal, 4)
                        }

                        if let duplicateWarning {
                            Text(duplicateWarning)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.orange)
                                .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Add Connection")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !prefilledTargetName.isEmpty {
                    targetName = prefilledTargetName
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveConnection()
                    }
                    .fontWeight(.semibold)
                    .disabled(isSaveDisabled)
                }
            }
        }
    }

    private var isSaveDisabled: Bool {
        let trimmedTarget = targetName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTarget.isEmpty { return true }

        if isCustomRelationship {
            let fwd = customForward.trimmingCharacters(in: .whitespacesAndNewlines)
            let rev = customReverse.trimmingCharacters(in: .whitespacesAndNewlines)
            if fwd.isEmpty || rev.isEmpty { return true }
        }

        return false
    }

    private func saveConnection() {
        errorMessage = nil
        duplicateWarning = nil

        let forwardPhrase = isCustomRelationship
            ? customForward.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            : selectedPreset.forward

        let reversePhrase = isCustomRelationship
            ? customReverse.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            : selectedPreset.reverse

        let targetEntity: Entity
        if let existing = targetSelectedEntity {
            targetEntity = existing
        } else {
            let trimmedName = targetName.trimmingCharacters(in: .whitespacesAndNewlines)
            let newEntity = Entity(name: trimmedName, type: targetType)
            modelContext.insert(newEntity)
            targetEntity = newEntity
        }

        // Validate self-connection
        if sourceEntity.id == targetEntity.id {
            errorMessage = "An entity cannot connect to itself."
            return
        }

        // Validate duplicate connection
        let existingConnection = sourceEntity.outgoing.first { conn in
            conn.to?.id == targetEntity.id && conn.relationshipType.lowercased() == forwardPhrase.lowercased()
        }

        if existingConnection != nil {
            errorMessage = "This connection already exists between \(sourceEntity.name) and \(targetEntity.name)."
            return
        }

        let connection = Connection(
            from: sourceEntity,
            to: targetEntity,
            relationshipType: forwardPhrase,
            reverseRelationshipType: reversePhrase
        )

        modelContext.insert(connection)
        try? modelContext.save()

        dismiss()
    }
}
