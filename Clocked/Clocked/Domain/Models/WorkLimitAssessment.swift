//
//  WorkLimitAssessment.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import Foundation

/// What one fortnight window looks like once a shift or offer is included.
struct FortnightWindowAssessment: Hashable {
    let window: FortnightWindow
    let countedHours: WorkedHours
    let verdict: ComplianceVerdict
}

/// The full answer to "can I take this shift?", across every fortnight the shift touches.
///
/// The tightest window is the one the student is shown, because the shift is only safe if it
/// fits in all of them. The interpretation name travels with the answer so the app can say
/// which reading of the rule produced it.
struct WorkLimitAssessment {
    let windows: [FortnightWindowAssessment]
    let tightest: FortnightWindowAssessment
    let interpretationName: String

    var verdict: ComplianceVerdict { tightest.verdict }
}
