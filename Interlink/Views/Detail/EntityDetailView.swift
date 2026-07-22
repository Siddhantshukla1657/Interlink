import SwiftUI
import SwiftData
import MapKit

struct EntityDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var entity: Entity

    @State private var isEditingNotes = false
    @State private var showAddConnectionSheet = false
    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var selectedConnectedEntity: Entity? = nil

    private var groupedOutgoing: [String: [Connection]] {
        Dictionary(grouping: entity.outgoing, by: { $0.relationshipType })
    }

    private var groupedIncoming: [String: [Connection]] {
        Dictionary(grouping: entity.incoming, by: { $0.reverseRelationshipType })
    }

    private var totalConnectionCount: Int {
        entity.outgoing.count + entity.incoming.count
    }

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {

                    // Profile Header Block
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(entity.type.color.opacity(0.2))
                                .frame(width: 84, height: 84)

                            if let data = entity.imageData, let img = UIImage(data: data) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 84, height: 84)
                                    .clipShape(Circle())
                            } else if entity.type == .person {
                                Text(entity.initials)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(entity.type.color)
                            } else {
                                Image(systemName: entity.type.icon)
                                    .font(.system(size: 38, weight: .semibold))
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

                    // Embedded Map for Place/Person entities with coordinates
                    if (entity.type == .place || entity.type == .person), let lat = entity.latitude, let lon = entity.longitude {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("LOCATION")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)

                            Map(position: .constant(.camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), distance: 1500)))) {
                                Annotation(entity.name, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title)
                                        .foregroundStyle(entity.type.color)
                                }
                            }
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                    }

                    // NOTES Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("NOTES")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)

                            Spacer()

                            Button {
                                isEditingNotes.toggle()
                                if !isEditingNotes {
                                    try? modelContext.save()
                                }
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
                            Text("Connections (\(totalConnectionCount))")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.primary)

                            Spacer()

                            Button {
                                showAddConnectionSheet = true
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

                        if totalConnectionCount == 0 {
                            VStack(spacing: 12) {
                                Text("No connections yet")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Button {
                                    showAddConnectionSheet = true
                                } label: {
                                    Label("Connect to Entity", systemImage: "plus")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .buttonStyle(.bordered)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .glassCard(cornerRadius: 16, padding: 16)
                        } else {
                            // Outgoing connection groups
                            ForEach(Array(groupedOutgoing.keys.sorted()), id: \.self) { relationshipType in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(relationshipType.uppercased())
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.secondary)

                                    VStack(spacing: 8) {
                                        ForEach(groupedOutgoing[relationshipType] ?? []) { conn in
                                            if let target = conn.to {
                                                Button {
                                                    selectedConnectedEntity = target
                                                } label: {
                                                    EntityRowView(entity: target)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                }
                            }

                            // Incoming connection groups
                            ForEach(Array(groupedIncoming.keys.sorted()), id: \.self) { reversePhrase in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(reversePhrase.uppercased())
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.secondary)

                                    VStack(spacing: 8) {
                                        ForEach(groupedIncoming[reversePhrase] ?? []) { conn in
                                            if let source = conn.from {
                                                Button {
                                                    selectedConnectedEntity = source
                                                } label: {
                                                    EntityRowView(entity: source)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                }
                            }
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
                Menu {
                    Button {
                        showEditSheet = true
                    } label: {
                        Label("Edit Entity", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Entity", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color(red: 0.1, green: 0.45, blue: 0.95))
                }
            }
        }
        .sheet(isPresented: $showAddConnectionSheet) {
            AddConnectionView(sourceEntity: entity)
        }
        .sheet(isPresented: $showEditSheet) {
            EditEntityView(entity: entity)
        }
        .navigationDestination(item: $selectedConnectedEntity) { connected in
            EntityDetailView(entity: connected)
        }
        .alert("Delete Entity?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                modelContext.delete(entity)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(entity.name)\"? This will cascade-delete all \(totalConnectionCount) connection(s) referencing it.")
        }
    }
}
