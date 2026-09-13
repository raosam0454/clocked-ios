//
//  SetupSheet.swift
//  Clocked
//
//  Created by Sumangala Rao on 10/9/2026.
//
import SwiftUI

/// One time setup: venues and term dates. Without these the app cannot answer anything.
struct SetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SetupViewModel

    init(dependencies: AppDependencies) {
        _viewModel = State(initialValue: SetupViewModel(dependencies: dependencies))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(viewModel.employers) { employer in
                        Text(employer.tradingName)
                    }
                    HStack {
                        TextField("Venue name", text: $viewModel.newVenueName)
                        Button("Add") { viewModel.addVenue() }
                            .tint(ClockedTheme.accent)
                    }
                } header: {
                    Text("Your venues").monoLabel()
                } footer: {
                    Text("Hours from every venue are added into one total.")
                }
                .listRowBackground(ClockedTheme.surface)

                Section {
                    ForEach(viewModel.periods) { period in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(period.name)
                            Text("\(period.firstDay.formatted(date: .abbreviated, time: .omitted)) to "
                                 + "\(period.lastDay.formatted(date: .abbreviated, time: .omitted)), "
                                 + period.mode.studentFacingLabel)
                                .font(.footnote)
                                .foregroundStyle(ClockedTheme.secondaryInk)
                        }
                    }

                    TextField("Period name", text: $viewModel.periodName)
                    DatePicker("First day", selection: $viewModel.firstDay, displayedComponents: .date)
                    DatePicker("Last day", selection: $viewModel.lastDay, displayedComponents: .date)
                    Picker("This period is", selection: $viewModel.mode) {
                        ForEach(StudyMode.allCases, id: \.self) { mode in
                            Text(mode.studentFacingLabel).tag(mode)
                        }
                    }
                    Button("Add period") { viewModel.addPeriod() }
                        .tint(ClockedTheme.accent)
                } header: {
                    Text("Your term dates").monoLabel()
                } footer: {
                    Text("The limit applies while your course is in session. Hours during a scheduled break are not limited.")
                }
                .listRowBackground(ClockedTheme.surface)

                if let problem = viewModel.problem {
                    Section {
                        Text(problem).foregroundStyle(ClockedTheme.breach)
                    }
                    .listRowBackground(ClockedTheme.surface)
                }
            }
            .navigationTitle("Setup")
            .clockedBackground()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear { viewModel.refresh() }
        }
    }
}

#Preview {
    SetupSheet(dependencies: .withSampleData())
}
