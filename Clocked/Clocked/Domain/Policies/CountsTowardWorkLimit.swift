//
//  CountsTowardsWorkLimit.swift
//  Clocked
//
//  Created by Sumangala Rao on 5/9/2026.
//
import Foundation

/// Work that can be measured against the visa limit: a recorded shift or a proposed one.
protocol CountsTowardWorkLimit {
    var period: DateInterval { get }
    var engagementType: WorkEngagementType { get }
}

extension CountsTowardWorkLimit {
    /// How many of these hours fall inside the window and count toward the limit.
    ///
    /// The shift is walked one date at a time, so a shift running past midnight is counted
    /// against each date separately. A date is counted only when the course is in session on
    /// that date. Dates the student has not covered with a study period count as zero here;
    /// the use case refuses to give a verdict in that case rather than answering from a gap.
    func countedHours(in window: FortnightWindow,
                      courseCalendar: CourseCalendar,
                      using calendar: Calendar) -> WorkedHours {
        guard engagementType.countsTowardWorkLimit else { return .zero }

        var total = WorkedHours.zero
        for day in calendar.days(covering: period) {
            guard window.covers(day, using: calendar),
                  courseCalendar.isLimited(on: day, using: calendar) == true,
                  let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else { continue }

            let dayInterval = DateInterval(start: day, end: nextDay)
            if let overlap = period.intersection(with: dayInterval) {
                total = total + WorkedHours(seconds: overlap.duration)
            }
        }
        return total
    }
}

extension WorkShift: CountsTowardWorkLimit {}
extension ShiftOffer: CountsTowardWorkLimit {}
