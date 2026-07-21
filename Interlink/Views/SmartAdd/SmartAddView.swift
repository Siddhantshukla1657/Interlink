import SwiftUI
import SwiftData

struct SmartAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let sourceEntity: Entity?

    @State private var sentence = ""
    @State private var extractedCandidates: [ExtractedNameCandidate] = []
    @State private var selectedCandidate: ExtractedNameCandidate? = nil
    @State private var showAddConnectionSheet = false

    @Query private var allEntities: [Entity]

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                VStack(alignment: .leading, spacing: 20) {
                    Text("SMART INPUT")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.secondary)

                    VStack(alignment: .leading, spacing: 8) {
                        ZStack(alignment: .topLeading) {
                            if sentence.isEmpty {
                                Text("What happened? e.g. \"Grabbed coffee with Priya and discussed Perkfolio\"")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(12)
                                    .allowsHitTesting(false)
                            }
                            TextEditor(text: $sentence)
                                .font(.subheadline)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .frame(height: 120)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )

                        Button {
                            runExtraction()
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Find Entities")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(Color(red: 0.1, green: 0.45, blue: 0.95)))
                            .foregroundStyle(.white)
                        }
                        .disabled(sentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }

                    if !extractedCandidates.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("EXTRACTED ENTITIES (TAP TO CONNECT)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(extractedCandidates) { candidate in
                                        let existing = findExistingEntity(for: candidate.name)

                                        Button {
                                            selectedCandidate = candidate
                                            showAddConnectionSheet = true
                                        } label: {
                                            HStack(spacing: 6) {
                                                Circle()
                                                    .fill(candidate.suggestedType.color)
                                                    .frame(width: 8, height: 8)

                                                Text(candidate.name)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)

                                                if existing != nil {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.caption)
                                                        .foregroundStyle(.green)
                                                } else {
                                                    Image(systemName: "plus.circle.fill")
                                                        .font(.caption)
                                                        .foregroundStyle(.blue)
                                                }
                                            }
                                            .glassPill(isSelected: false)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 10)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .navigationTitle("Smart Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showAddConnectionSheet) {
                if let source = sourceEntity ?? allEntities.first {
                    AddConnectionView(sourceEntity: source, prefilledTargetName: selectedCandidate?.name ?? "")
                }
            }
        }
    }

    private func runExtraction() {
        extractedCandidates = NameExtractionService.extractNames(from: sentence)
    }

    private func findExistingEntity(for name: String) -> Entity? {
        let norm = DedupSearchService.normalize(name)
        return allEntities.first { $0.normalizedName == norm }
    }
}
