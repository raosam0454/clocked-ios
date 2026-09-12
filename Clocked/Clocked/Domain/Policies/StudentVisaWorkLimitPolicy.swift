//
//  StudentVisaWorkLimitPolicy.swift
//  Clocked
//
//  Created by Sumangala Rao on 5/9/2026.
//
import Foundation

/// The work limit itself: how many hours are allowed in a window, and how close is too close.
///
/// The cap is a value rather than a number written into the logic, because the rule has changed
/// before: it was 40 hours a fortnight until mid 2023.
struct StudentVisaWorkLimitPolicy {
    let capHours: WorkedHours

    /// How near the cap the student is warned rather than cleared.
    let warningBufferHours: WorkedHours

    /// How a fortnight is measured. The window length comes from here, so there is one source
    /// of truth for it.
    let interpretation: any FortnightInterpretation

    /// Student visa condition 8105 as Clocked enforces it: 48 hours, strictest reading.
    static let condition8105 = StudentVisaWorkLimitPolicy(
        capHours: WorkedHours(48),
        warningBufferHours: WorkedHours(4),
        interpretation: RollingFortnightInterpretation()
    )

    /// The answer for one window, given the hours already counted in it.
    func verdict(forCountedHours hours: WorkedHours) -> ComplianceVerdict {
        if hours > capHours {
            return .wouldBreach(excess: hours - capHours)
        }
        let remaining = capHours - hours
        if remaining <= warningBufferHours {
            return .approachingLimit(remaining: remaining)
        }
        return .withinLimit(remaining: remaining)
    }
}
