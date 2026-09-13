//
//  ExportWorkRecordUseCase.swift
//  Clocked
//
//  Created by Sumangala Rao on 10/9/2026.
//
import Foundation

/// A plain text record of the hours a student has worked, ready to be shown to someone.
struct WorkRecordExport {
    let generatedAt: Date
    let text: String
}

enum WorkRecordExportError: LocalizedError, Equatable {
    case noShiftsRecorded

    var errorDescription: String? {
        switch self {
        case .noShiftsRecorded:
            return "There are no shifts in your record yet. Add a shift first."
        }
    }
}

/// Produces the record a student could show if their hours were ever questioned.
///
/// The export states that hours are entered by the student and which reading of the fortnight
/// rule was applied, because a record that overstates what it proves is worse than none.
struct ExportWorkRecordUseCase {
    private let shiftRepository: ShiftRepository
    private let employerRepository: EmployerRepository
    private let courseCalendarRepository: CourseCalendarRepository
    private let policy: StudentVisaWorkLimitPolicy
    private let calendar: Calendar

    init(shiftRepository: ShiftRepository,
         employerRepository: EmployerRepository,
         courseCalendarRepository: CourseCalendarRepository,
         policy: StudentVisaWorkLimitPolicy = .condition8105,
         calendar: Calendar = .current) {
        self.shiftRepository = shiftRepository
        self.employerRepository = employerRepository
        self.courseCalendarRepository = courseCalendarRepository
        self.policy = policy
        self.calendar = calendar
    }

    func execute(asOf generatedAt: Date = Date()) throws -> WorkRecordExport {
        let shifts = shiftRepository.allShifts().sorted { $0.period.start < $1.period.start }
        guard !shifts.isEmpty else { throw WorkRecordExportError.noShiftsRecorded }

        let courseCalendar = courseCalendarRepository.courseCalendar()
        var lines: [String] = []
        lines.append("WORK RECORD")
        lines.append("Generated \(generatedAt.formatted(date: .abbreviated, time: .shortened))")
        lines.append("Limit applied: \(format(policy.capHours)) hours per fortnight, counted using \(policy.interpretation.name)")
        lines.append("")

        var totals: [EmployerIdentifier: WorkedHours] = [:]
        for shift in shifts {
            let venue = employerRepository.employer(with: shift.employerID)?.tradingName ?? "Unknown venue"
            let counted = countedHours(for: shift, courseCalendar: courseCalendar)
            totals[shift.employerID] = (totals[shift.employerID] ?? .zero) + counted

            let day = shift.period.start.formatted(date: .abbreviated, time: .omitted)
            let from = shift.period.start.formatted(date: .omitted, time: .shortened)
            let to = shift.period.end.formatted(date: .omitted, time: .shortened)
            let countedNote = counted > .zero
                ? "\(format(counted))h counted"
                : "not counted toward the limit"
            lines.append("\(day)  \(from) to \(to)  \(venue)  \(format(shift.scheduledDuration))h worked, \(countedNote)")
        }

        lines.append("")
        lines.append("TOTAL COUNTED HOURS BY VENUE")
        for (employerID, hours) in totals.sorted(by: { $0.value > $1.value }) {
            let venue = employerRepository.employer(with: employerID)?.tradingName ?? "Unknown venue"
            lines.append("\(venue): \(format(hours))h")
        }

        lines.append("")
        lines.append("Hours are entered by the student and are not verified against payslips or rosters.")
        lines.append("This record is not legal advice.")

        return WorkRecordExport(generatedAt: generatedAt, text: lines.joined(separator: "\n"))
    }

    /// Hours that counted, measured over a window starting on the day of the shift.
    private func countedHours(for shift: WorkShift, courseCalendar: CourseCalendar) -> WorkedHours {
        let window = FortnightWindow(firstDay: shift.period.start,
                                     lengthInDays: policy.interpretation.lengthInDays,
                                     using: calendar)
        return shift.countedHours(in: window, courseCalendar: courseCalendar, using: calendar)
    }

    private func format(_ hours: WorkedHours) -> String {
        hours.value.formatted(.number.precision(.fractionLength(0...1)))
    }
}
