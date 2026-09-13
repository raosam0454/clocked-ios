//
//  RecordShiftUseCase.swift
//  Clocked
//
//  Created by Sumangala Rao on 10/9/2026.
//
import Foundation

/// Why a shift could not be recorded. Each message names the fix, because the student is
/// usually mid conversation with a manager when they see it.
enum ShiftRecordingError: LocalizedError, Equatable {
    /// Start and finish are the same moment.
    case shiftHasNoHours

    /// More than a day long, which is nearly always a mistyped date.
    case shiftLongerThanADay

    /// The student is already rostered somewhere at that time.
    case overlapsExistingShift(venue: String)

    /// The venue has not been added yet, so its hours would not count anywhere.
    case employerNotRecognised

    var errorDescription: String? {
        switch self {
        case .shiftHasNoHours:
            return "This shift has no hours in it. Check the start and finish times."
        case .shiftLongerThanADay:
            return "That shift is longer than a day. Check the dates before saving."
        case .overlapsExistingShift(let venue):
            return "You already have a shift at \(venue) that overlaps this one. "
                 + "You cannot be at both, so fix whichever one is wrong."
        case .employerNotRecognised:
            return "Add this venue to your employers first, so its hours count toward your total."
        }
    }
}

/// Adds a shift the student has worked or accepted to their work record.
///
/// A shift may be in the future, because a student accepts a shift before working it. Recording
/// is deliberately separate from judging: this operation refuses impossible entries, but it
/// never blocks a shift for being over the limit. The student may have worked it already, and
/// hiding that would make the record useless as evidence.
struct RecordShiftUseCase {
    private let shiftRepository: ShiftRepository
    private let employerRepository: EmployerRepository
    private let studentID: StudentIdentifier
    private let calendar: Calendar

    init(shiftRepository: ShiftRepository,
         employerRepository: EmployerRepository,
         studentID: StudentIdentifier,
         calendar: Calendar = .current) {
        self.shiftRepository = shiftRepository
        self.employerRepository = employerRepository
        self.studentID = studentID
        self.calendar = calendar
    }

    @discardableResult
    func execute(employerID: EmployerIdentifier,
                 period: DateInterval,
                 engagementType: WorkEngagementType = .paid,
                 note: String? = nil) throws -> WorkShift {
        guard period.duration > 0 else {
            throw ShiftRecordingError.shiftHasNoHours
        }
        guard period.duration <= 24 * 3600 else {
            throw ShiftRecordingError.shiftLongerThanADay
        }
        guard employerRepository.employer(with: employerID) != nil else {
            throw ShiftRecordingError.employerNotRecognised
        }

        for existing in shiftRepository.allShifts() {
            // Shifts that merely touch, one finishing as the next starts, do not overlap.
            if let shared = period.intersection(with: existing.period), shared.duration > 0 {
                let venue = employerRepository.employer(with: existing.employerID)?.tradingName ?? "another venue"
                throw ShiftRecordingError.overlapsExistingShift(venue: venue)
            }
        }

        let shift = WorkShift(employerID: employerID,
                              period: period,
                              engagementType: engagementType,
                              recordedByStudentID: studentID,
                              note: note)
        shiftRepository.add(shift)
        return shift
    }
}
