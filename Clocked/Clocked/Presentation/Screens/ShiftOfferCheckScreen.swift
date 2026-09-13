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
                askSection

                if let problem = viewModel.problem {
                    Section {
                        Text(problem).foregroundStyle(ClockedTheme.secondaryInk)
                    }
                    .listRowBackground(ClockedTheme.surface)
                }

                if let confirmation = viewModel.confirmation {
                    Section {
                        Text(confirmation).foregroundStyle(ClockedTheme.safe)
                    }
                    .listRowBackground(ClockedTheme.surface)
                }

                if viewModel.assessment != nil {
                    answerSection
                    windowsSection
                    disclaimerSection
                }
            }
            .navigationTitle("Check a shift")
            .clockedBackground()
        }
    }

    private var offerSection: some View {
        Section {
            Picker("Venue", selection: $viewModel.employerID) {
                ForEach(viewModel.employers) { employer in
                    Text(employer.tradingName).tag(Optional(employer.id))
                }
            }

            DatePicker("Starts", selection: $viewModel.startsAt)

            Stepper(value: $viewModel.lengthInHours, in: 0.5...16, step: 0.5) {
                Text("Length: \(viewModel.lengthInHours.formatted(.number.precision(.fractionLength(0...1)))) hours")
                    .monospacedDigit()
            }

            Picker("Type of work", selection: $viewModel.engagementType) {
                ForEach(WorkEngagementType.allCases, id: \.self) { type in
                    Text(type.studentFacingLabel).tag(type)
                }
            }

            Text(viewModel.engagementType.studentFacingHint)
                .font(.footnote)
                .foregroundStyle(ClockedTheme.secondaryInk)
        } header: {
            Text("The shift").monoLabel()
        }
        .listRowBackground(ClockedTheme.surface)
    }

    private var askSection: some View {
        Section {
            Button {
                viewModel.check()
            } label: {
                Text("Can I take this?")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(ClockedTheme.accent)
            .listRowInsets(EdgeInsets())
        }
        .listRowBackground(Color.clear)
    }

    private var answerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                VerdictBanner(tone: viewModel.tone, headline: viewModel.headline)
                Text(viewModel.detail)
                    .foregroundStyle(ClockedTheme.ink)
            }
            .padding(.vertical, 4)

            Button("I took this shift") { viewModel.accept() }
                .tint(ClockedTheme.accent)
        } header: {
            Text("The answer").monoLabel()
        }
        .listRowBackground(ClockedTheme.surface)
    }

    private var windowsSection: some View {
        Section {
            ForEach(viewModel.tightestWindows) { window in
                HStack {
                    Text(window.range)
                        .monospacedDigit()
                        .foregroundStyle(ClockedTheme.ink)
                    Spacer()
                    Text(window.hours)
                        .monospacedDigit()
                        .foregroundStyle(window.tone.color)
                }
            }
        } header: {
            Text("Fortnights this shift falls in").monoLabel()
        }
        .listRowBackground(ClockedTheme.surface)
    }

    private var disclaimerSection: some View {
        Section {
            Text(viewModel.interpretationText)
                .font(.footnote)
                .foregroundStyle(ClockedTheme.secondaryInk)
        }
        .listRowBackground(Color.clear)
    }
}

#Preview {
    ShiftOfferCheckScreen(dependencies: .withSampleData())
}
