//
//  Theme.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import SwiftUI
import UIKit

/// The app's colours, in one place.
///
/// Deep navy on a cool off white: the palette compliance and government products use, because
/// it reads as steady rather than exciting. Green, amber and red are reserved for the verdict,
/// and are muted so they carry meaning rather than decoration.
enum ClockedTheme {
    /// The page behind everything.
    static let canvas = adaptive(light: 0xE6EDF4, dark: 0x0E1418)

    /// Cards and rows that sit on the canvas.
    static let surface = adaptive(light: 0xFFFFFF, dark: 0x18212B)

    /// Buttons, links and selected controls.
    static let accent = adaptive(light: 0x14385C, dark: 0x8FBBE6)

    static let safe = adaptive(light: 0x2E7D5B, dark: 0x5FCF9E)
    static let warning = adaptive(light: 0xB26B00, dark: 0xE0A34A)
    static let breach = adaptive(light: 0xB3261E, dark: 0xF2837B)

    /// Picks a colour per appearance, so dark mode works without a second code path.
    private static func adaptive(light: UInt, dark: UInt) -> Color {
        Color(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

extension MeterTone {
    var color: Color {
        switch self {
        case .safe: return ClockedTheme.safe
        case .warning: return ClockedTheme.warning
        case .breach: return ClockedTheme.breach
        }
    }
}

/// Puts every screen on the same background.
private struct ClockedBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(ClockedTheme.canvas.ignoresSafeArea())
    }
}

/// A panel sitting on the canvas: white in light mode, slate in dark.
private struct ClockedCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ClockedTheme.surface, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}

extension View {
    func clockedBackground() -> some View {
        modifier(ClockedBackground())
    }

    func clockedCard() -> some View {
        modifier(ClockedCard())
    }
}

private extension UIColor {
    convenience init(hex: UInt) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}
