//
//  FortnightMeterScreen.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import SwiftUI

/// The home screen: where the student stands right now, across every employer.
struct FortnightMeterScreen: View {
    @State private var viewModel: FortnightMeterViewModel

    init(dependencies: AppDependencies) {
        _viewModel = State(initialValue: FortnightMeterViewModel(dependencies: dependencies))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let problem = viewModel.problem {
                        needsSetup(problem).clockedCard()
                    } else {
                        meterCard
                        breakdownCard
                        Text(viewModel.interpretationText)
                            .font(.footnote)
                            .foregroundStyle(ClockedTheme.secondaryInk)
                            .padding(.horizontal, 4)
                    }
                }
                .padding(16)
            }
            .navigationTitle("This fortnight")
            .clockedBackground()
            .onAppear { viewModel.refresh() }
        }
    }

    private var meterCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("In session")
                .monoLabel()

            MeterRing(fraction: viewModel.fillFraction,
                      tone: viewModel.tone,
                      value: viewModel.meterValueText,
                      caption: "hours")
                .frame(maxWidth: .infinity)

            Text(viewModel.remainingText)
                .font(.headline)
                .foregroundStyle(viewModel.tone.color)
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(spacing: 2) {
                Text("Tightest window").monoLabel()
                Text(viewModel.windowRangeText)
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(ClockedTheme.ink)
            }
            .frame(maxWidth: .infinity)
        }
        .clockedCard()
    }

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Counted toward the cap").monoLabel()

            if viewModel.employers.isEmpty {
                Text("No shifts recorded in this fortnight yet.")
                    .foregroundStyle(ClockedTheme.secondaryInk)
            } else {
                ForEach(viewModel.employers, id: \.employerID) { employer in
                    HStack {
                        Text(employer.tradingName)
                            .foregroundStyle(ClockedTheme.ink)
                        Spacer()
                        Text("\(employer.hours.value.formatted(.number.precision(.fractionLength(0...1))))h")
                            .monospacedDigit()
                            .foregroundStyle(ClockedTheme.secondaryInk)
                    }
                }
            }
        }
        .clockedCard()
    }

    private func needsSetup(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Set up your term dates").monoLabel()
            Text(message)
                .foregroundStyle(ClockedTheme.ink)
        }
    }
}

#Preview {
    FortnightMeterScreen(dependencies: .withSampleData())
}
