//
//  FortnightInterpretation.swift
//  Clocked
//
//  Created by Sumangala Rao on 5/9/2026.
//
import Foundation

/// How "a fortnight" is measured.
///
/// This is the unsettled question in the domain. Official wording says 48 hours per fortnight,
/// but published guidance disagrees on what a fortnight is, and the readings give opposite
/// answers for the same roster. Each reading is a separate type so the app can enforce one and
/// still show the student what the other would have said.
protocol FortnightInterpretation {
    /// Wording shown to the student, so the app never hides which reading it used.
    var name: String { get }

    var lengthInDays: Int { get }

    /// Every window this stretch of work falls inside.
    func windows(touching period: DateInterval, using calendar: Calendar) -> [FortnightWindow]
}

/// Any 14 consecutive days, the strictest reading. This is the one Clocked enforces.
///
/// Work on a given date sits inside 14 different windows: the one starting that day, and the
/// thirteen that started on the days before it.
struct RollingFortnightInterpretation: FortnightInterpretation {
    let lengthInDays: Int

    init(lengthInDays: Int = 14) {
        self.lengthInDays = lengthInDays
    }

    var name: String { "any \(lengthInDays) consecutive days" }

    func windows(touching period: DateInterval, using calendar: Calendar) -> [FortnightWindow] {
        var firstDaysSeen = Set<Date>()
        var windows: [FortnightWindow] = []

        for day in calendar.days(covering: period) {
            for offset in 0..<lengthInDays {
                guard let start = calendar.date(byAdding: .day, value: -offset, to: day) else { continue }
                let window = FortnightWindow(firstDay: start, lengthInDays: lengthInDays, using: calendar)
                if firstDaysSeen.insert(window.firstDay).inserted {
                    windows.append(window)
                }
            }
        }
        return windows.sorted { $0.firstDay < $1.firstDay }
    }
}

/// Fixed blocks counted from a reference Monday, the more lenient reading.
///
/// Kept so the two readings can be compared. Under this reading 30 hours in one week and 30 in
/// the next can be compliant, while the rolling reading calls the same roster a breach.
struct FixedBlockFortnightInterpretation: FortnightInterpretation {
    let lengthInDays: Int
    let anchorDay: Date

    /// Monday 3 July 2023, when the 48 hour cap took effect.
    static let ruleStartMonday: Date = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Australia/Sydney") ?? .current
        var components = DateComponents()
        components.year = 2023
        components.month = 7
        components.day = 3
        return calendar.date(from: components) ?? Date(timeIntervalSince1970: 0)
    }()

    init(lengthInDays: Int = 14, anchorDay: Date = FixedBlockFortnightInterpretation.ruleStartMonday) {
        self.lengthInDays = lengthInDays
        self.anchorDay = anchorDay
    }

    var name: String { "fixed \(lengthInDays) day blocks" }

    func windows(touching period: DateInterval, using calendar: Calendar) -> [FortnightWindow] {
        let anchor = calendar.startOfDay(for: anchorDay)
        var firstDaysSeen = Set<Date>()
        var windows: [FortnightWindow] = []

        for day in calendar.days(covering: period) {
            let daysFromAnchor = calendar.dateComponents([.day], from: anchor, to: day).day ?? 0
            let blockIndex = Int(floor(Double(daysFromAnchor) / Double(lengthInDays)))
            guard let start = calendar.date(byAdding: .day,
                                            value: blockIndex * lengthInDays,
                                            to: anchor) else { continue }
            let window = FortnightWindow(firstDay: start, lengthInDays: lengthInDays, using: calendar)
            if firstDaysSeen.insert(window.firstDay).inserted {
                windows.append(window)
            }
        }
        return windows.sorted { $0.firstDay < $1.firstDay }
    }
}
