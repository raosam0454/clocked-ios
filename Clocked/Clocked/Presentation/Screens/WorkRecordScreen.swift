//
//  WorkRecordScreen.swift
//  Clocked
//
//  Created by Sumangala Rao on 10/9/2026.
//
import SwiftUI

/// The proof side of the app: what has been worked, and a record that can be handed over.
struct WorkRecordScreen: View {
    let dependencies: AppDependencies
    @State private var viewModel: WorkRecordViewModel
    @State private var isShowingSetup = false

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = State(initialValue: WorkRecordViewModel(dependencies: dependencies))
    }

    var body: some View {
        NavigationStack {
            List {
                if viewModel.rows.isEmpty {
                    Section {
                        Text("No shifts recorded yet.")
                            .foregroundStyle(ClockedTheme.secondaryInk)
                    }
                    .listRowBackground(ClockedTheme.surface)
                } else {
                    Section {
                        ForEach(viewModel.rows) { row in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(row.dateText)
                                        .font(.subheadline.weight(.semibold))
                                        .monospacedDigit()
                                        .foregroundStyle(ClockedTheme.ink)
                                    Spacer()
                                    Text(row.hoursText)
                                        .monospacedDigit()
                                        .foregroundStyle(ClockedTheme.ink)
                                }
                                HStack {
                                    Text("\(row.venue), \(row.timesText)")
                                        .font(.footnote)
                                        .foregroundStyle(ClockedTheme.secondaryInk)
                                    Spacer()
                                    if !row.countsTowardCap {
                                        Text("exempt")
                                            .font(.system(.caption2, design: .monospaced))
                                            .foregroundStyle(ClockedTheme.secondaryInk)
                                    }
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    } header: {
                        Text("Your shifts").monoLabel()
                    }
                    .listRowBackground(ClockedTheme.surface)
                }

                if let exportText = viewModel.exportText {
                    Section {
                        ShareLink(item: exportText) {
                            Label("Share my work record", systemImage: "square.and.arrow.up")
                        }
                        .tint(ClockedTheme.accent)
                    } footer: {
                        Text("Hours are entered by you and are not verified against payslips.")
                    }
                    .listRowBackground(ClockedTheme.surface)
                }
            }
            .navigationTitle("Work record")
            .clockedBackground()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Setup") { isShowingSetup = true }
                }
            }
            .sheet(isPresented: $isShowingSetup, onDismiss: { viewModel.refresh() }) {
                SetupSheet(dependencies: dependencies)
            }
            .onAppear { viewModel.refresh() }
        }
    }
}

#Preview {
    WorkRecordScreen(dependencies: .withSampleData())
}
