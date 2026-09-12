import Foundation

/// Why the meter cannot be shown.
enum WorkLimitStatusError: LocalizedError, Equatable {
    /// The student has not entered a study period covering today.
    case termDatesMissing

    var errorDescription: String? {
        switch self {
        case .termDatesMissing:
            return "Add your term dates to see your fortnight total. "
                 + "The limit only applies while your course is in session."
        }
    }
}

/// Works out the live meter: hours used and hours left, across every employer.
///
/// Today sits inside fourteen overlapping windows, and the student is only safe if they are
/// inside the limit in all of them, so the fullest one is the one reported.
struct CalculateWorkLimitStatusUseCase {
    private let shiftRepository: ShiftRepository
    private let employerRepository: EmployerRepository
    private let courseCalendarRepository: CourseCalendarRepository
    private let policy: StudentVisaWorkLimitPolicy
    private let calendar: Calendar

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

    func execute(asOf today: Date = Date()) throws -> WorkLimitStatus {
        let courseCalendar = courseCalendarRepository.courseCalendar()
        guard courseCalendar.mode(on: today, using: calendar) != nil else {
            throw WorkLimitStatusError.termDatesMissing
        }

        let startOfToday = calendar.startOfDay(for: today)
        let wholeDay = DateInterval(start: startOfToday, duration: 24 * 3600)
        let windows = policy.interpretation.windows(touching: wholeDay, using: calendar)
        let shifts = shiftRepository.allShifts()

        var tightest: FortnightWindowAssessment?
        for window in windows {
            var hours = WorkedHours.zero
            for shift in shifts {
                hours = hours + shift.countedHours(in: window,
                                                   courseCalendar: courseCalendar,
                                                   using: calendar)
            }
            let assessment = FortnightWindowAssessment(window: window,
                                                       countedHours: hours,
                                                       verdict: policy.verdict(forCountedHours: hours))
            if tightest == nil || hours > tightest!.countedHours {
                tightest = assessment
            }
        }

        let reported = tightest ?? FortnightWindowAssessment(
            window: FortnightWindow(firstDay: startOfToday,
                                    lengthInDays: policy.interpretation.lengthInDays,
                                    using: calendar),
            countedHours: .zero,
            verdict: policy.verdict(forCountedHours: .zero)
        )

        return WorkLimitStatus(asOf: today,
                               tightest: reported,
                               hoursByEmployer: breakdown(in: reported.window,
                                                          shifts: shifts,
                                                          courseCalendar: courseCalendar),
                               interpretationName: policy.interpretation.name)
    }

    /// Hours inside the reported window, grouped by venue, busiest first.
    private func breakdown(in window: FortnightWindow,
                           shifts: [WorkShift],
                           courseCalendar: CourseCalendar) -> [EmployerHours] {
        var totals: [EmployerIdentifier: WorkedHours] = [:]
        for shift in shifts {
            let hours = shift.countedHours(in: window,
                                           courseCalendar: courseCalendar,
                                           using: calendar)
            guard hours > .zero else { continue }
            totals[shift.employerID] = (totals[shift.employerID] ?? .zero) + hours
        }

        return totals
            .map { employerID, hours in
                EmployerHours(employerID: employerID,
                              tradingName: employerRepository.employer(with: employerID)?.tradingName ?? "Unknown venue",
                              hours: hours)
            }
            .sorted { $0.hours > $1.hours }
    }
}
