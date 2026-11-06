import SwiftUI

struct WorkshopCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(.primary.opacity(0.09), lineWidth: 1)
            }
    }
}

extension View {
    func workshopCard() -> some View {
        modifier(WorkshopCard())
    }
}
