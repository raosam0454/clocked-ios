//
//  EngagementTypeDisplay.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import Foundation

/// Wording for each kind of work, kept out of the domain because labels are a screen decision
/// and change far more often than the rule behind them.
extension WorkEngagementType {
    var studentFacingLabel: String {
        switch self {
        case .paid: return "Paid shift"
        case .unpaidOrVolunteer: return "Unpaid or volunteer"
        case .requiredCoursePlacement: return "Required course placement"
        }
    }

    var studentFacingHint: String {
        switch self {
        case .paid: return "Counts toward your limit."
        case .unpaidOrVolunteer: return "Still counts toward your limit."
        case .requiredCoursePlacement: return "Does not count toward your limit."
        }
    }
}

/// Wording for the two kinds of study period.
extension StudyMode {
    var studentFacingLabel: String {
        switch self {
        case .inSession: return "In session"
        case .courseBreak: return "Course break"
        }
    }
}
