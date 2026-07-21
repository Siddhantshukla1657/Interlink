import SwiftUI

struct EntityRowView: View {
    let entity: Entity

    var body: some View {
        HStack(spacing: 12) {
            if let imageData = entity.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(entity.type.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Text(String(entity.name.prefix(1)).uppercased())
                        .font(.headline)
                        .foregroundStyle(entity.type.color)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entity.name)
                    .font(.body)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Circle()
                        .fill(entity.type.color)
                        .frame(width: 6, height: 6)
                    Text(entity.type.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
    }
}
