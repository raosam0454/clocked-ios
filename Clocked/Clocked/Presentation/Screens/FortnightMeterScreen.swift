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
                VStack(alignment: .leading, spacing: 24) {
                    if let problem = viewModel.problem {
                        needsSetup(problem)
                    } else {
                        meter
                        breakdown
                        Text(viewModel.interpretationText)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("This fortnight")
            .onAppear { viewModel.refresh() }
        }
    }

    private var meter: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(viewModel.hoursUsedText)
                    .font(.system(size: 56, weight: .semibold, design: .rounded))
                Text("of \(viewModel.capText) hours")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: viewModel.fillFraction)
                .tint(color(for: viewModel.tone))

            Text(viewModel.remainingText)
                .font(.headline)
                .foregroundStyle(color(for: viewModel.tone))

            Text(viewModel.windowText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var breakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Counted toward the cap")
                .font(.headline)

            if viewModel.employers.isEmpty {
                Text("No shifts recorded in this fortnight yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.employers, id: \.employerID) { employer in
                    HStack {
                        Text(employer.tradingName)
                        Spacer()
                        Text("\(employer.hours.value.formatted(.number.precision(.fractionLength(0...1))))h")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func needsSetup(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Set up your term dates")
                .font(.title2.bold())
            Text(message)
                .foregroundStyle(.secondary)
        }
    }

    private func color(for tone: MeterTone) -> Color {
        switch tone {
        case .safe: return .green
        case .warning: return .orange
        case .breach: return .red
        }
    }
}

#Preview {
    FortnightMeterScreen(dependencies: .withSampleData())
}
