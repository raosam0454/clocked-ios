//
//  RecordShiftScreen.swift
//  Clocked
//
//  Created by Sumangala Rao on 10/9/2026.
//
import SwiftUI

/// Ten second entry: a shift that was worked, or one that has just been accepted.
struct RecordShiftScreen: View {
    @State private var viewModel: RecordShiftViewModel

    init(dependencies: AppDependencies) {
        _viewModel = State(initialValue: RecordShiftViewModel(dependencies: dependencies))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Venue", selection: $viewModel.employerID) {
                        ForEach(viewModel.employers) { employer in
                            Text(employer.tradingName).tag(Optional(employer.id))
                        }
                    }

                    DatePicker("Date", selection: $viewModel.day, displayedComponents: .date)
                    DatePicker("Start", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                    DatePicker("Finish", selection: $viewModel.finishTime, displayedComponents: .hourAndMinute)

                    HStack {
                        Text(viewModel.lengthText).monospacedDigit()
                        if viewModel.finishesNextDay {
                            Text("finishes next day")
                                .font(.footnote)
                                .foregroundStyle(ClockedTheme.secondaryInk)
                        }
                    }
                } header: {
                    Text("Add shift").monoLabel()
                }
                .listRowBackground(ClockedTheme.surface)

                Section {
                    Picker("Type of work", selection: $viewModel.engagementType) {
                        ForEach(WorkEngagementType.allCases, id: \.self) { type in
                            Text(type.studentFacingLabel).tag(type)
                        }
                    }
                    Text(viewModel.engagementType.studentFacingHint)
                        .font(.footnote)
                        .foregroundStyle(ClockedTheme.secondaryInk)
                } header: {
                    Text("Counts toward the cap").monoLabel()
                }
                .listRowBackground(ClockedTheme.surface)

                Section {
                    Button {
                        viewModel.save()
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ClockedTheme.accent)
                    .listRowInsets(EdgeInsets())
                }
                .listRowBackground(Color.clear)

                if let problem = viewModel.problem {
                    Section {
                        Text(problem).foregroundStyle(ClockedTheme.breach)
                    }
                    .listRowBackground(ClockedTheme.surface)
                }

                if let confirmation = viewModel.confirmation {
                    Section {
                        Text(confirmation).foregroundStyle(ClockedTheme.safe)
                    }
                    .listRowBackground(ClockedTheme.surface)
                }
            }
            .navigationTitle("Add a shift")
            .clockedBackground()
        }
    }
}

#Preview {
    RecordShiftScreen(dependencies: .withSampleData())
}
