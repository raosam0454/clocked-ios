//
//  WorkLimitStatus.swift
//  Clocked
//
//  Created by Sumangala Rao on 10/9/2026.
//
import Foundation

/// Hours worked at one employer, inside whichever window is being reported.
struct EmployerHours: Hashable {
    let employerID: EmployerIdentifier
    let tradingName: String
    let hours: WorkedHours
}

/// Where the student stands right now: the fullest fortnight window they are inside, and who
/// those hours belong to.
///
/// The breakdown by employer is here because the total is the number that matters, but the
/// student can only act on it if they can see which venue it came from.
struct WorkLimitStatus {
    let asOf: Date
    let tightest: FortnightWindowAssessment
    let hoursByEmployer: [EmployerHours]
    let interpretationName: String

    var verdict: ComplianceVerdict { tightest.verdict }
}
