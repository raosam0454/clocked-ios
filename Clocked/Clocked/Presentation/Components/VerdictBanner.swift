//
//  VerdictBanner.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import SwiftUI

/// The bordered answer strip from the deck: one word, in the verdict's colour.
struct VerdictBanner: View {
    let tone: MeterTone
    let headline: String

    var body: some View {
        HStack(spacing: 10) {
            Text(tone.bannerText)
                .font(.system(.subheadline, design: .monospaced).bold())
                .tracking(1.5)
            Text(headline)
                .font(.subheadline.weight(.semibold))
            Spacer(minLength: 0)
        }
        .foregroundStyle(tone.color)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(tone.color, lineWidth: 1.5)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        VerdictBanner(tone: .safe, headline: "You can take this shift")
        VerdictBanner(tone: .warning, headline: "You can take it, but only just")
        VerdictBanner(tone: .breach, headline: "Taking this would put you over")
    }
    .padding()
    .background(ClockedTheme.canvas)
}
