//
//  CalendarDays.swift
//  Clocked
//
//  Created by Sumangala Rao on 5/9/2026.
//
import Foundation

extension Calendar {
    /// Every calendar date the interval touches, as start of day dates.
    ///
    /// A shift ending exactly at midnight does not touch the next day, so 6pm to midnight is
    /// one date, not two.
    func days(covering interval: DateInterval) -> [Date] {
        let firstDay = startOfDay(for: interval.start)
        var endReference = interval.end
        if interval.duration > 0 && endReference == startOfDay(for: endReference) {
            endReference = endReference.addingTimeInterval(-1)
        }
        let lastDay = startOfDay(for: endReference)

        var days: [Date] = []
        var day = firstDay
        while day <= lastDay {
            days.append(day)
            guard let next = date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return days
    }
}
