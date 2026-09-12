//
//  FortnightWindow.swift
//  Clocked
//
//  Created by Sumangala Rao on 5/9/2026.
//
import Foundation

/// A 14 day stretch that the work limit can be measured over.
///
/// Both ends are whole days and both are included, so a window starting 2 March ends on
/// 15 March.
struct FortnightWindow: Hashable {
    let firstDay: Date
    let lastDay: Date

    init(firstDay: Date, lengthInDays: Int, using calendar: Calendar) {
        let start = calendar.startOfDay(for: firstDay)
        self.firstDay = start
        self.lastDay = calendar.date(byAdding: .day, value: lengthInDays - 1, to: start) ?? start
    }

    func covers(_ date: Date, using calendar: Calendar) -> Bool {
        let day = calendar.startOfDay(for: date)
        return day >= firstDay && day <= lastDay
    }
}
