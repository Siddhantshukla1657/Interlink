import UIKit

struct ImageProcessingService {
    static func processAndCompress(_ image: UIImage, maxDimension: CGFloat = 200, quality: CGFloat = 0.65) -> Data? {
        let size = image.size
        guard size.width > 0 && size.height > 0 else { return nil }

        let scale = min(maxDimension / size.width, maxDimension / size.height, 1.0)
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return resizedImage.jpegData(compressionQuality: quality)
    }
}
