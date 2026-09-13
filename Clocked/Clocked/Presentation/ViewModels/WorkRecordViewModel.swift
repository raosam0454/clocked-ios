//
//  WorkRecordViewModel.swift
//  Clocked
//
//  Created by Sumangala Rao on 10/9/2026.
//
import Foundation
import Observation

/// One shift as it appears in the history list.
struct WorkRecordRow: Identifiable {
    let id: UUID
    let dateText: String
    let timesText: String
    let venue: String
    let hoursText: String
    let countsTowardCap: Bool
}

/// Screen state for the work record: what has been worked, and the record to show if asked.
@MainActor
@Observable
final class WorkRecordViewModel {
    private let shiftRepository: ShiftRepository
    private let employerRepository: EmployerRepository
    private let exportRecord: ExportWorkRecordUseCase

    private(set) var rows: [WorkRecordRow] = []
    private(set) var exportText: String?
    private(set) var problem: String?

    init(dependencies: AppDependencies) {
        self.shiftRepository = dependencies.shiftRepository
        self.employerRepository = dependencies.employerRepository
        self.exportRecord = dependencies.makeExportWorkRecordUseCase()
    }

    func refresh() {
        rows = shiftRepository.allShifts()
            .sorted { $0.period.start > $1.period.start }
            .map { shift in
                WorkRecordRow(
                    id: shift.id.value,
                    dateText: shift.period.start.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)),
                    timesText: "\(shift.period.start.formatted(date: .omitted, time: .shortened)) to "
                             + "\(shift.period.end.formatted(date: .omitted, time: .shortened))",
                    venue: employerRepository.employer(with: shift.employerID)?.tradingName ?? "Unknown venue",
                    hoursText: "\(shift.scheduledDuration.value.formatted(.number.precision(.fractionLength(0...1))))h",
                    countsTowardCap: shift.engagementType.countsTowardWorkLimit
                )
            }

        do {
            exportText = try exportRecord.execute().text
            problem = nil
        } catch {
            exportText = nil
            problem = error.localizedDescription
        }
    }
}
