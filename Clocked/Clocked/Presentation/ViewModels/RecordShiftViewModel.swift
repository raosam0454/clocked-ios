//
//  RecordShiftViewModel.swift
//  Clocked
//
//  Created by Sumangala Rao on 10/9/2026.
//
import Foundation
import Observation

/// Screen state for adding a shift that has been worked or accepted.
///
/// Times are entered as a day plus a start and finish, which is how a roster reads. A finish
/// time earlier than the start means the shift runs past midnight, so the finish belongs to the
/// next day. Assuming otherwise would reject the most ordinary hospitality shift there is.
@MainActor
@Observable
final class RecordShiftViewModel {
    private let record: RecordShiftUseCase
    private let employerRepository: EmployerRepository
    private let calendar: Calendar

    var employerID: EmployerIdentifier?
    var day: Date
    var startTime: Date
    var finishTime: Date
    var engagementType: WorkEngagementType = .paid

    private(set) var problem: String?
    private(set) var confirmation: String?

    init(dependencies: AppDependencies, now: Date = Date()) {
        self.record = dependencies.makeRecordShiftUseCase()
        self.employerRepository = dependencies.employerRepository
        self.calendar = dependencies.calendar
        self.day = now
        self.startTime = now
        self.finishTime = now.addingTimeInterval(5 * 3600)
        self.employerID = dependencies.employerRepository.allEmployers().first?.id
    }

    var employers: [Employer] {
        employerRepository.allEmployers().filter { !$0.isArchived }
    }

    /// True when the finish time lands on the following day.
    var finishesNextDay: Bool {
        guard let period else { return false }
        return !calendar.isDate(period.start, inSameDayAs: period.end)
    }

    var lengthText: String {
        guard let period else { return "" }
        let hours = period.duration / 3600
        return "\(hours.formatted(.number.precision(.fractionLength(0...1)))) hours"
    }

    func save() {
        guard let employerID else {
            problem = "Choose which venue the shift was at."
            return
        }
        guard let period else {
            problem = "Check the start and finish times."
            return
        }
        do {
            try record.execute(employerID: employerID,
                               period: period,
                               engagementType: engagementType)
            confirmation = "Shift saved to your work record."
            problem = nil
        } catch {
            confirmation = nil
            problem = error.localizedDescription
        }
    }

    private var period: DateInterval? {
        let start = combine(day: day, time: startTime)
        var finish = combine(day: day, time: finishTime)
        if finish <= start {
            finish = calendar.date(byAdding: .day, value: 1, to: finish) ?? finish
        }
        guard finish > start else { return nil }
        return DateInterval(start: start, end: finish)
    }

    private func combine(day: Date, time: Date) -> Date {
        let dayParts = calendar.dateComponents([.year, .month, .day], from: day)
        let timeParts = calendar.dateComponents([.hour, .minute], from: time)
        var parts = DateComponents()
        parts.year = dayParts.year
        parts.month = dayParts.month
        parts.day = dayParts.day
        parts.hour = timeParts.hour
        parts.minute = timeParts.minute
        return calendar.date(from: parts) ?? day
    }
}
