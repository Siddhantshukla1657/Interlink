import SwiftUI
import SwiftData
import PhotosUI

struct EntityCreationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedType: EntityType = .person
    @State private var notes = ""
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var selectedEntity: Entity? = nil

    // Place location search
    @StateObject private var locationSearch = LocationSearchService()
    @State private var addressQuery: String = ""
    @State private var latitude: Double? = nil
    @State private var longitude: Double? = nil
    @State private var selectedAddressTitle: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Photo Upload Container
                        VStack(spacing: 8) {
                            PhotosPicker(selection: $photoItem, matching: .images) {
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

                                    if let data = selectedImageData, let uiImg = UIImage(data: data) {
                                        Image(uiImage: uiImg)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 84, height: 84)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 26))
                                            .foregroundStyle(Color(red: 0.1, green: 0.45, blue: 0.95))
                                    }
                                }
                            }
                            .onChange(of: photoItem) { _, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let uiImg = UIImage(data: data),
                                       let compressed = ImageProcessingService.processAndCompress(uiImg) {
                                        selectedImageData = compressed
                                    }
                                }
                            }

                            Text("ADD PHOTO")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)

                        // ENTITY NAME & DEDUP MATCHES
                        VStack(alignment: .leading, spacing: 6) {
                            Text("ENTITY NAME")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)

                            NameFieldWithMatches(text: $name, selectedEntity: $selectedEntity)
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

                        // PLACE LOCATION SEARCH
                        if selectedType == .place {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("LOCATION ADDRESS")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)

                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundStyle(Color.secondary)
                                    TextField("Search address for map coordinates...", text: $addressQuery)
                                        .font(.subheadline)
                                        .onChange(of: addressQuery) { _, newValue in
                                            locationSearch.search(query: newValue)
                                        }
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

                                if !selectedAddressTitle.isEmpty {
                                    Text("Selected: \(selectedAddressTitle)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                if !locationSearch.results.isEmpty {
                                    VStack(alignment: .leading, spacing: 0) {
                                        ForEach(locationSearch.results.prefix(4)) { res in
                                            Button {
                                                latitude = res.coordinate.latitude
                                                longitude = res.coordinate.longitude
                                                selectedAddressTitle = res.title
                                                addressQuery = res.title
                                                locationSearch.results = []
                                            } label: {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(res.title)
                                                        .font(.subheadline)
                                                        .fontWeight(.semibold)
                                                        .foregroundStyle(.primary)
                                                    Text(res.subtitle)
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
                                                .padding(10)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            Divider()
                                        }
                                    }
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
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
                                        .foregroundStyle(.secondary)
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
            notes: notes,
            imageData: selectedImageData
        )
        entity.latitude = latitude
        entity.longitude = longitude

        modelContext.insert(entity)
        try? modelContext.save()
        dismiss()
    }
}
