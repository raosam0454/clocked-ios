//
//  CourseCalendar.swift
//  Clocked
//
//  Created by Sumangala Rao on 3/9/2026.
//
import Foundation

/// The study periods the student has entered, used to decide whether a given date is limited.
///
/// A date the student has not covered with any period returns `nil` rather than a guess.
/// Guessing in either direction is unsafe: assume a break and the app under counts hours,
/// assume in session and it warns about a free period. The app asks the student instead.
struct CourseCalendar: Hashable, Codable {
    var periods: [StudyPeriod]

    init(periods: [StudyPeriod] = []) {
        self.periods = periods
    }

    /// The study mode that applies on a date, or `nil` when no period covers it.
    func mode(on date: Date, using calendar: Calendar) -> StudyMode? {
        periods.first { $0.covers(date, using: calendar) }?.mode
    }

    /// Whether the work limit applies on a date. `nil` when the date is not covered.
    func isLimited(on date: Date, using calendar: Calendar) -> Bool? {
        guard let mode = mode(on: date, using: calendar) else { return nil }
        return mode == .inSession
    }
}
