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
            Form {
                Section {
                    NameFieldWithMatches(text: $name, selectedEntity: $selectedEntity)
                } header: {
                    Text("Name")
                } footer: {
                    if selectedEntity != nil {
                        Label("This matches an existing entity. Tap to view it instead.", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }

                Section("Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(EntityType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                        .overlay(alignment: .topLeading) {
                            if notes.isEmpty {
                                Text("Add notes (optional)")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                }
            }
            .navigationTitle("New Entity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntity()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onChange(of: selectedEntity) { _, newValue in
                if newValue != nil {
                    dismiss()
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

        do {
            try modelContext.save()
        } catch {
            print("Failed to save entity: \(error)")
        }

        dismiss()
    }
}
