//
//  WorkShift.swift
//  Clocked
//
//  Created by Sumangala Rao on 3/9/2026.
//
import Foundation

/// A block of work at one employer, either already worked or accepted for a future date.
///
/// A shift that crosses midnight belongs to both dates: hours are counted against each
/// calendar date separately, because course breaks and fortnight windows start on a date.
/// `scheduledDuration` is the length of the shift, which is not the same as the hours that
/// count toward the visa limit.
struct WorkShift: Identifiable, Hashable, Codable {
    let id: ShiftIdentifier
    let employerID: EmployerIdentifier

    /// When the shift starts and ends.
    var period: DateInterval

    var engagementType: WorkEngagementType

    /// When the student logged this shift. Kept so the record can be exported as evidence.
    let recordedAt: Date
    let recordedByStudentID: StudentIdentifier

    var note: String?

    /// The length of the shift, before any exemptions are applied.
    var scheduledDuration: WorkedHours {
        WorkedHours(seconds: period.duration)
    }

    init(id: ShiftIdentifier = ShiftIdentifier(),
         employerID: EmployerIdentifier,
         period: DateInterval,
         engagementType: WorkEngagementType = .paid,
         recordedAt: Date = Date(),
         recordedByStudentID: StudentIdentifier,
         note: String? = nil) {
        self.id = id
        self.employerID = employerID
        self.period = period
        self.engagementType = engagementType
        self.recordedAt = recordedAt
        self.recordedByStudentID = recordedByStudentID
        self.note = note
    }
}
