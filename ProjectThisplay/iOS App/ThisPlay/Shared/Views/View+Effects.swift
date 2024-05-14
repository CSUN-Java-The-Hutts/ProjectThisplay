//
//  ViewGlowEffect.swift
//  ThisPlay
//
import SwiftUI

struct GlowEffect: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        let glowColor = colorScheme == .light ? Color.indigo.opacity(0.25) : Color.purple.opacity(0.25)
        let glowColorSecondary = colorScheme == .light ? Color.mint.opacity(0.65) : Color.teal.opacity(0.65)

        return content
            .overlay(
                content
                    .shadow(color: glowColor, radius: 5, x: 0.5, y: 1.5)
                    .shadow(color: glowColorSecondary, radius: 5, x: 0.5, y: 3.0)
            )
    }
}

extension View {
    func glowEffect() -> some View {
        self.modifier(GlowEffect())
    }
}
