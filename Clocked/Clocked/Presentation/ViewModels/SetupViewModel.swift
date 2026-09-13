//
//  SetupViewModel.swift
//  Clocked
//
//  Created by Sumangala Rao on 10/9/2026.
//
import Foundation
import Observation

/// Screen state for the one time setup: the venues the student works at, and their term dates.
@MainActor
@Observable
final class SetupViewModel {
    private let employerRepository: EmployerRepository
    private let courseCalendarRepository: CourseCalendarRepository

    var newVenueName = ""
    var periodName = ""
    var firstDay = Date()
    var lastDay = Date()
    var mode: StudyMode = .inSession

    private(set) var employers: [Employer] = []
    private(set) var periods: [StudyPeriod] = []
    private(set) var problem: String?

    init(dependencies: AppDependencies) {
        self.employerRepository = dependencies.employerRepository
        self.courseCalendarRepository = dependencies.courseCalendarRepository
    }

    func refresh() {
        employers = employerRepository.allEmployers()
        periods = courseCalendarRepository.courseCalendar().periods
            .sorted { $0.firstDay < $1.firstDay }
    }

    func addVenue() {
        let name = newVenueName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            problem = "Give the venue a name, as it appears on your roster."
            return
        }
        employerRepository.add(Employer(tradingName: name))
        newVenueName = ""
        problem = nil
        refresh()
    }

    func addPeriod() {
        let name = periodName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            problem = "Name this period, for example Spring session."
            return
        }
        guard lastDay >= firstDay else {
            problem = "The last day cannot be before the first day."
            return
        }
        var courseCalendar = courseCalendarRepository.courseCalendar()
        courseCalendar.periods.append(StudyPeriod(name: name,
                                                  firstDay: firstDay,
                                                  lastDay: lastDay,
                                                  mode: mode))
        courseCalendarRepository.save(courseCalendar)
        periodName = ""
        problem = nil
        refresh()
    }
}
