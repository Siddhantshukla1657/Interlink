import SwiftUI

struct TypeChipPicker: View {
    @Binding var selected: EntityType?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(EntityType.allCases) { type in
                    Button {
                        selected = type
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: type.icon)
                                .font(.caption)
                            Text(type.rawValue)
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            selected == type
                                ? AnyShapeStyle(type.color)
                                : AnyShapeStyle(.quaternary)
                        )
                        .foregroundStyle(selected == type ? .white : .primary)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
