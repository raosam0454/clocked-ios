//
//  MeterRing.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import SwiftUI

/// The fortnight meter: hours used out of the cap, drawn as a ring.
///
/// A ring rather than a bar because the fortnight is a fixed budget, not progress toward a
/// goal, and a closing circle reads as "how much is left" at a glance.
struct MeterRing: View {
    let fraction: Double
    let tone: MeterTone
    let value: String
    let caption: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(ClockedTheme.ringTrack, lineWidth: 14)

            Circle()
                .trim(from: 0, to: min(max(fraction, 0.001), 1))
                .stroke(tone.color, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.35), value: fraction)

            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(ClockedTheme.ink)
                Text(caption)
                    .monoLabel()
            }
        }
        .frame(width: 196, height: 196)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(value) \(caption)")
    }
}

#Preview {
    VStack(spacing: 24) {
        MeterRing(fraction: 0.7, tone: .safe, value: "34/48", caption: "hours")
        MeterRing(fraction: 0.98, tone: .warning, value: "47/48", caption: "hours")
    }
    .padding()
    .background(ClockedTheme.canvas)
}
