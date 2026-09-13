//
//  ShiftOfferCheckScreen.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import SwiftUI

/// The decision moment: a roster message has arrived and the student has minutes to answer.
struct ShiftOfferCheckScreen: View {
    @State private var viewModel: ShiftOfferCheckViewModel

    init(dependencies: AppDependencies) {
        _viewModel = State(initialValue: ShiftOfferCheckViewModel(dependencies: dependencies))
    }

    var body: some View {
        NavigationStack {
            Form {
                offerSection

                Section {
                    Button("Can I take this?") { viewModel.check() }
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                }

                if let problem = viewModel.problem {
                    Section { Text(problem).foregroundStyle(.secondary) }
                }

                if let confirmation = viewModel.confirmation {
                    Section { Text(confirmation).foregroundStyle(ClockedTheme.safe) }
                }

                if viewModel.assessment != nil {
                    answerSection
                    windowsSection
                }
            }
            .navigationTitle("Check a shift")
            .clockedBackground()
        }
    }

    private var offerSection: some View {
        Section("The shift") {
            Picker("Venue", selection: $viewModel.employerID) {
                ForEach(viewModel.employers) { employer in
                    Text(employer.tradingName).tag(Optional(employer.id))
                }
            }

            DatePicker("Starts", selection: $viewModel.startsAt)

            Stepper(value: $viewModel.lengthInHours, in: 0.5...16, step: 0.5) {
                Text("Length: \(viewModel.lengthInHours.formatted(.number.precision(.fractionLength(0...1)))) hours")
            }

            Picker("Type of work", selection: $viewModel.engagementType) {
                ForEach(WorkEngagementType.allCases, id: \.self) { type in
                    Text(type.studentFacingLabel).tag(type)
                }
            }

            Text(viewModel.engagementType.studentFacingHint)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var answerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.headline)
                    .font(.title3.bold())
                    .foregroundStyle(viewModel.tone.color)
                Text(viewModel.detail)
                Text(viewModel.interpretationText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)

            Button("I took this shift") { viewModel.accept() }
        }
    }

    private var windowsSection: some View {
        Section("Fortnights this shift falls in") {
            ForEach(viewModel.tightestWindows) { window in
                HStack {
                    Text(window.range)
                    Spacer()
                    Text(window.hours)
                        .monospacedDigit()
                        .foregroundStyle(window.tone.color)
                }
            }
        }
    }
}

#Preview {
    ShiftOfferCheckScreen(dependencies: .withSampleData())
}
