import SwiftUI

struct FilterChipRow: View {
    @Binding var selectedTypes: Set<EntityType>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // "All" chip
                let isAllSelected = selectedTypes.count == EntityType.allCases.count
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTypes = Set(EntityType.allCases)
                    }
                } label: {
                    Text("All")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .glassPill(isSelected: isAllSelected, activeColor: Color(red: 0.1, green: 0.45, blue: 0.95))
                        .foregroundStyle(isAllSelected ? .white : .primary)
                }

                // Category type chips
                ForEach(EntityType.allCases) { type in
                    let isSelected = !isAllSelected && selectedTypes.contains(type) && selectedTypes.count == 1
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTypes = [type]
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
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }
}
