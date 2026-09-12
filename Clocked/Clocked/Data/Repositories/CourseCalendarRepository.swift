//
//  CourseCalendarRepository.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import Foundation

/// Where the student's term dates are kept.
protocol CourseCalendarRepository: AnyObject {
    func courseCalendar() -> CourseCalendar
    func save(_ courseCalendar: CourseCalendar)
}

final class InMemoryCourseCalendarRepository: CourseCalendarRepository {
    private var calendar: CourseCalendar

    init(courseCalendar: CourseCalendar = CourseCalendar()) {
        self.calendar = courseCalendar
    }

    func courseCalendar() -> CourseCalendar {
        calendar
    }

    func save(_ courseCalendar: CourseCalendar) {
        calendar = courseCalendar
    }
}
