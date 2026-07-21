import SwiftUI

struct EntityRowView: View {
    let entity: Entity

    var body: some View {
        HStack(spacing: 14) {
            // Avatar Circle
            ZStack {
                Circle()
                    .fill(entity.type.color.opacity(0.18))
                    .frame(width: 44, height: 44)

                if let data = entity.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                } else if entity.type == .person {
                    Text(entity.initials)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(entity.type.color)
                } else {
                    Image(systemName: entity.type.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(entity.type.color)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entity.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                HStack(spacing: 5) {
                    Circle()
                        .fill(entity.type.color)
                        .frame(width: 6, height: 6)

                    Text(entity.type.rawValue.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .glassCard(cornerRadius: 16, padding: 12)
    }
}
