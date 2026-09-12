//
//  DomainFixtures.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import Foundation
@testable import Clocked

/// Shared building blocks for the domain tests.
///
/// Every test uses one fixed calendar and time zone. Date rules break in interesting ways at
/// midnight, so tests must not depend on where the machine running them happens to be.
enum Fixtures {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Australia/Sydney") ?? .current
        return calendar
    }()

    static let student = StudentIdentifier()

    static func date(_ year: Int, _ month: Int, _ day: Int, at hour: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        return calendar.date(from: components)!
    }

    /// A shift starting at a given hour on a given date, lasting a number of hours.
    static func period(_ year: Int, _ month: Int, _ day: Int,
                       from hour: Int, hours: Double) -> DateInterval {
        DateInterval(start: date(year, month, day, at: hour), duration: hours * 3600)
    }

    static func shift(at employerID: EmployerIdentifier,
                      _ year: Int, _ month: Int, _ day: Int,
                      from hour: Int,
                      hours: Double,
                      engagementType: WorkEngagementType = .paid) -> WorkShift {
        WorkShift(employerID: employerID,
                  period: period(year, month, day, from: hour, hours: hours),
                  engagementType: engagementType,
                  recordedByStudentID: student)
    }

    /// Semester running for the whole of the test period.
    static func semester() -> CourseCalendar {
        CourseCalendar(periods: [
            StudyPeriod(name: "Autumn session",
                        firstDay: date(2026, 2, 2),
                        lastDay: date(2026, 4, 30),
                        mode: .inSession)
        ])
    }

    /// A semester that stops on 6 March, followed by a course break.
    static func semesterWithBreakFrom7March() -> CourseCalendar {
        CourseCalendar(periods: [
            StudyPeriod(name: "Autumn session",
                        firstDay: date(2026, 2, 2),
                        lastDay: date(2026, 3, 6),
                        mode: .inSession),
            StudyPeriod(name: "Mid session break",
                        firstDay: date(2026, 3, 7),
                        lastDay: date(2026, 3, 22),
                        mode: .courseBreak)
        ])
    }
}
