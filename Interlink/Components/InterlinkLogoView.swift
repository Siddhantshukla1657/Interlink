import SwiftUI

struct InterlinkLogoView: View {
    var size: CGFloat = 36

    var body: some View {
        Image("InterlinkLogo")
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: size, height: size)
    }
}
