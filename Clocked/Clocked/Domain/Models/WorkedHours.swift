import Foundation

/// An amount of work time in hours, the unit the visa limit is written in.
///
/// A separate type keeps hours from being added to counts of shifts or days by accident.
/// Negative time has no meaning here, so it is clamped to zero; a shift that ends before it
/// starts is rejected earlier, when it is recorded.
struct WorkedHours: Hashable, Comparable, Codable {
    /// Hours. 7.5 means seven hours thirty minutes.
    let value: Double

    init(_ value: Double) {
        self.value = Swift.max(0, value)
    }

    /// Builds hours from a duration in seconds, which is what `DateInterval.duration` returns.
    init(seconds: TimeInterval) {
        self.init(seconds / 3600)
    }

    static let zero = WorkedHours(0)

    static func + (lhs: WorkedHours, rhs: WorkedHours) -> WorkedHours {
        WorkedHours(lhs.value + rhs.value)
    }

    static func - (lhs: WorkedHours, rhs: WorkedHours) -> WorkedHours {
        WorkedHours(lhs.value - rhs.value)
    }

    static func < (lhs: WorkedHours, rhs: WorkedHours) -> Bool {
        lhs.value < rhs.value
    }
}
