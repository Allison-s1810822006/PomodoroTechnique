import SwiftUI

struct ButtonStyleWithHighlight: ButtonStyle {
    var normalBackground: Color
    var highlightedBackground: Color
    var normalForeground: Color
    var highlightedForeground: Color
    var cornerRadius: CGFloat = 8
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? highlightedForeground : normalForeground)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(configuration.isPressed ? highlightedBackground : normalBackground)
            )
    }
}
