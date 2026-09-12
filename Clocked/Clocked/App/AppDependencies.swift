//
//  AppDependencies.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import Foundation

/// Creates the repositories once and builds use cases on demand.
///
/// This is the only place in the app where a concrete repository is named. Screens ask for a
/// use case and never see storage, so replacing the in memory store later changes this file
/// and nothing else.
final class AppDependencies {
    let shiftRepository: ShiftRepository
    let employerRepository: EmployerRepository
    let courseCalendarRepository: CourseCalendarRepository
    let studentID: StudentIdentifier
    let calendar: Calendar

    init(shiftRepository: ShiftRepository = InMemoryShiftRepository(),
         employerRepository: EmployerRepository = InMemoryEmployerRepository(),
         courseCalendarRepository: CourseCalendarRepository = InMemoryCourseCalendarRepository(),
         studentID: StudentIdentifier = StudentIdentifier(),
         calendar: Calendar = .current) {
        self.shiftRepository = shiftRepository
        self.employerRepository = employerRepository
        self.courseCalendarRepository = courseCalendarRepository
        self.studentID = studentID
        self.calendar = calendar
    }

    func makeCalculateWorkLimitStatusUseCase() -> CalculateWorkLimitStatusUseCase {
        CalculateWorkLimitStatusUseCase(shiftRepository: shiftRepository,
                                        employerRepository: employerRepository,
                                        courseCalendarRepository: courseCalendarRepository,
                                        calendar: calendar)
    }

    func makeRecordShiftUseCase() -> RecordShiftUseCase {
        RecordShiftUseCase(shiftRepository: shiftRepository,
                           employerRepository: employerRepository,
                           studentID: studentID,
                           calendar: calendar)
    }

    func makeEvaluateShiftOfferUseCase() -> EvaluateShiftOfferUseCase {
        EvaluateShiftOfferUseCase(shiftRepository: shiftRepository,
                                  employerRepository: employerRepository,
                                  courseCalendarRepository: courseCalendarRepository,
                                  calendar: calendar)
    }

    /// A student partway through a semester, so the app has something to show on first launch.
    ///
    /// Stands in for real storage until it arrives.
    static func withSampleData(today: Date = Date()) -> AppDependencies {
        let calendar = Calendar.current
        let cafe = Employer(tradingName: "Cafe Nord")
        let pub = Employer(tradingName: "The Old Fitz")
        let student = StudentIdentifier()

        let semester = StudyPeriod(
            name: "This session",
            firstDay: calendar.date(byAdding: .day, value: -60, to: today) ?? today,
            lastDay: calendar.date(byAdding: .day, value: 60, to: today) ?? today,
            mode: .inSession
        )

        func shift(_ employerID: EmployerIdentifier, daysAgo: Int, from hour: Int, hours: Double) -> WorkShift {
            let day = calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
            let start = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day) ?? day
            return WorkShift(employerID: employerID,
                             period: DateInterval(start: start, duration: hours * 3600),
                             recordedByStudentID: student)
        }

        return AppDependencies(
            shiftRepository: InMemoryShiftRepository(shifts: [
                shift(cafe.id, daysAgo: 9, from: 9, hours: 8),
                shift(cafe.id, daysAgo: 8, from: 9, hours: 6),
                shift(pub.id, daysAgo: 6, from: 17, hours: 6),
                shift(cafe.id, daysAgo: 3, from: 9, hours: 8),
                shift(pub.id, daysAgo: 2, from: 17, hours: 6)
            ]),
            employerRepository: InMemoryEmployerRepository(employers: [cafe, pub]),
            courseCalendarRepository: InMemoryCourseCalendarRepository(
                courseCalendar: CourseCalendar(periods: [semester])
            ),
            studentID: student,
            calendar: calendar
        )
    }
}
