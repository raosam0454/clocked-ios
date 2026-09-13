//
//  Theme.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import SwiftUI

/// The app's colours, type styles and panel style, in one place.
///
/// A light reading of the pitch deck: the same navy, periwinkle and signal colours, inverted
/// onto a pale blue grey ground. Cards are separated by a thin border rather than a shadow, and
/// labels are monospaced and letter spaced, which is what gives the deck its steady, technical
/// feel.
enum ClockedTheme {
    static let canvas = Color(red: 0.914, green: 0.937, blue: 0.965)

    /// Cards sitting on the canvas.
    static let surface = Color.white
    static let cardBorder = Color(red: 0.804, green: 0.847, blue: 0.894)

    /// Deep navy, the colour headings and numbers are set in.
    static let ink = Color(red: 0.051, green: 0.082, blue: 0.125)
    static let secondaryInk = Color(red: 0.360, green: 0.420, blue: 0.494)

    /// Periwinkle from the deck, darkened enough to sit on white.
    static let accent = Color(red: 0.239, green: 0.388, blue: 0.659)

    /// The unfilled part of the meter ring.
    static let ringTrack = Color(red: 0.859, green: 0.890, blue: 0.925)

    static let safe = Color(red: 0.122, green: 0.541, blue: 0.341)
    static let warning = Color(red: 0.824, green: 0.322, blue: 0.122)
    static let breach = Color(red: 0.702, green: 0.149, blue: 0.118)
}

extension MeterTone {
    var color: Color {
        switch self {
        case .safe: return ClockedTheme.safe
        case .warning: return ClockedTheme.warning
        case .breach: return ClockedTheme.breach
        }
    }

    /// Short word for the verdict banner, so colour is never the only signal.
    var bannerText: String {
        switch self {
        case .safe: return "OK"
        case .warning: return "! CLOSE"
        case .breach: return "! OVER"
        }
    }
}

// MARK: - Styles

/// Small uppercase monospaced label, the deck's section heading.
private struct MonoLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.caption, design: .monospaced))
            .tracking(2)
            .textCase(.uppercase)
            .foregroundStyle(ClockedTheme.secondaryInk)
    }
}

/// A panel on the canvas: white, thin border, no shadow.
private struct ClockedCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ClockedTheme.surface, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(ClockedTheme.cardBorder, lineWidth: 1)
            )
    }
}

private struct ClockedBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(ClockedTheme.canvas.ignoresSafeArea())
    }
}

extension View {
    func monoLabel() -> some View { modifier(MonoLabel()) }
    func clockedCard() -> some View { modifier(ClockedCard()) }
    func clockedBackground() -> some View { modifier(ClockedBackground()) }
}
