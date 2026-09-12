//
//  ComplianceVerdict.swift
//  Clocked
//
//  Created by Sumangala Rao on 5/9/2026.
//
import Foundation

/// The answer the student gets about a fortnight window.
///
/// Being exactly on the cap is allowed, and reports zero hours remaining.
enum ComplianceVerdict: Hashable {
    /// Comfortably inside the limit.
    case withinLimit(remaining: WorkedHours)

    /// Still legal, but close enough that one more shift would break it.
    case approachingLimit(remaining: WorkedHours)

    /// Over the limit for this window.
    case wouldBreach(excess: WorkedHours)
}
