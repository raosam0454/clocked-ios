//
//  WorkEngagementType.swift
//  Clocked
//
//  Created by Sumangala Rao on 1/9/2026.
//
import Foundation

/// What kind of work a shift is, which decides whether its hours count toward the visa limit.
///
/// Unpaid and volunteer work counts, which surprises most students. A work placement required
/// by the student's course does not count.
enum WorkEngagementType: String, CaseIterable, Codable {
    case paid
    case unpaidOrVolunteer
    case requiredCoursePlacement

    /// Whether hours of this kind are measured against the limit.
    var countsTowardWorkLimit: Bool {
        self != .requiredCoursePlacement
    }
}
