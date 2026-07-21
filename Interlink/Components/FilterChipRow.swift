import SwiftUI

struct FilterChipRow: View {
    @Binding var selectedTypes: Set<EntityType>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "All", isSelected: selectedTypes == Set(EntityType.allCases)) {
                    selectedTypes = Set(EntityType.allCases)
                }

                ForEach(EntityType.allCases) { type in
                    filterChip(label: type.rawValue, isSelected: selectedTypes.contains(type)) {
                        if selectedTypes.contains(type) {
                            selectedTypes.remove(type)
                            if selectedTypes.isEmpty {
                                selectedTypes = Set(EntityType.allCases)
                            }
                        } else {
                            selectedTypes.insert(type)
                            if selectedTypes == Set(EntityType.allCases) {
                                // already all selected
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}
