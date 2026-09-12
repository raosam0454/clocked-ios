//
//  EvaluateShiftOfferUseCase..swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import Foundation

/// Why an offer could not be judged. Each message is written for a student holding a phone,
/// with the next action in it.
enum ShiftOfferEvaluationError: LocalizedError, Equatable {
    /// The proposed shift has no length.
    case offerHasNoHours

    /// The offer names a venue the student has not added yet.
    case employerNotRecognised

    /// The student's term dates do not cover the day of the offer.
    case termDatesMissing(forDay: Date)

    var errorDescription: String? {
        switch self {
        case .offerHasNoHours:
            return "This shift has no hours in it. Check the start and finish times."
        case .employerNotRecognised:
            return "Add this venue to your employers first, so its hours count toward your total."
        case .termDatesMissing:
            return "Clocked needs your term dates for this date before it can answer. "
                 + "The limit only applies while your course is in session."
        }
    }
}

/// Answers "can I take this shift?" before the student replies to the roster message.
///
/// Every fortnight window the shift touches is measured, not only the current one, because a
/// shift can be fine in the fortnight you are in and still break an overlapping one.
struct EvaluateShiftOfferUseCase {
    let shiftRepository: ShiftRepository
    let employerRepository: EmployerRepository
    let courseCalendarRepository: CourseCalendarRepository
    let policy: StudentVisaWorkLimitPolicy
    let calendar: Calendar

    init(shiftRepository: ShiftRepository,
         employerRepository: EmployerRepository,
         courseCalendarRepository: CourseCalendarRepository,
         policy: StudentVisaWorkLimitPolicy = .condition8105,
         calendar: Calendar = .current) {
        self.shiftRepository = shiftRepository
        self.employerRepository = employerRepository
        self.courseCalendarRepository = courseCalendarRepository
        self.policy = policy
        self.calendar = calendar
    }

    func execute(_ offer: ShiftOffer) throws -> WorkLimitAssessment {
        guard offer.period.duration > 0 else {
            throw ShiftOfferEvaluationError.offerHasNoHours
        }
        guard employerRepository.employer(with: offer.employerID) != nil else {
            throw ShiftOfferEvaluationError.employerNotRecognised
        }

        let courseCalendar = courseCalendarRepository.courseCalendar()
        for day in calendar.days(covering: offer.period) where courseCalendar.mode(on: day, using: calendar) == nil {
            throw ShiftOfferEvaluationError.termDatesMissing(forDay: day)
        }

        let recordedShifts = shiftRepository.allShifts()
        let windows = policy.interpretation.windows(touching: offer.period, using: calendar)

        let assessments = windows.map { window -> FortnightWindowAssessment in
            var hours = offer.countedHours(in: window, courseCalendar: courseCalendar, using: calendar)
            for shift in recordedShifts {
                hours = hours + shift.countedHours(in: window, courseCalendar: courseCalendar, using: calendar)
            }
            return FortnightWindowAssessment(window: window,
                                             countedHours: hours,
                                             verdict: policy.verdict(forCountedHours: hours))
        }

        // The shift is only safe if it fits every window, so the fullest one is the answer.
        let tightest = assessments.max { $0.countedHours < $1.countedHours }
            ?? FortnightWindowAssessment(window: FortnightWindow(firstDay: offer.period.start,
                                                                 lengthInDays: policy.interpretation.lengthInDays,
                                                                 using: calendar),
                                         countedHours: .zero,
                                         verdict: policy.verdict(forCountedHours: .zero))

        return WorkLimitAssessment(windows: assessments,
                                   tightest: tightest,
                                   interpretationName: policy.interpretation.name)
    }
}
