//
//  ShiftOffer.swift
//  Clocked
//
//  Created by Sumangala Rao on 5/9/2026.
//
import Foundation

/// A shift a manager has proposed and the student has not accepted yet.
///
/// It is measured exactly like a recorded shift, which is what lets the student see the answer
/// before replying rather than after the payslip arrives.
struct ShiftOffer: Hashable {
    let employerID: EmployerIdentifier
    var period: DateInterval
    var engagementType: WorkEngagementType

    init(employerID: EmployerIdentifier,
         period: DateInterval,
         engagementType: WorkEngagementType = .paid) {
        self.employerID = employerID
        self.period = period
        self.engagementType = engagementType
    }
}
