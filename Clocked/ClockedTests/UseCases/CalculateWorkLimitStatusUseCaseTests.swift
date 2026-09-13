//
//  CalculateWorkLimitStatusUseCaseTests.swift
//  Clocked
//
//  Created by Sumangala Rao on 10/9/2026.
//
import XCTest
@testable import Clocked

final class CalculateWorkLimitStatusUseCaseTests: XCTestCase {

    private let cafe = Employer(tradingName: "Cafe Nord")
    private let pub = Employer(tradingName: "The Old Fitz")

    private func makeUseCase(recorded: [WorkShift] = [],
                             courseCalendar: CourseCalendar = Fixtures.semester()) -> CalculateWorkLimitStatusUseCase {
        CalculateWorkLimitStatusUseCase(
            shiftRepository: InMemoryShiftRepository(shifts: recorded),
            employerRepository: InMemoryEmployerRepository(employers: [cafe, pub]),
            courseCalendarRepository: InMemoryCourseCalendarRepository(courseCalendar: courseCalendar),
            policy: .condition8105,
            calendar: Fixtures.calendar
        )
    }

    func test_workLimitStatus_addsHoursFromEveryEmployerIntoOneTotal() throws {
        let useCase = makeUseCase(recorded: [
            Fixtures.shift(at: cafe.id, 2026, 3, 9, from: 9, hours: 8),
            Fixtures.shift(at: pub.id, 2026, 3, 10, from: 17, hours: 6)
        ])

        let status = try useCase.execute(asOf: Fixtures.date(2026, 3, 11, at: 16))

        XCTAssertEqual(status.tightest.countedHours.value, 14, accuracy: 0.001)
    }

    func test_workLimitStatus_reportsTheFullestWindowTodaySitsIn() throws {
        // 30 hours in the week before, 12 this week. Neither week alone is near the cap, but
        // the window spanning both holds 42 of the 48 hours.
        let useCase = makeUseCase(recorded: [
            Fixtures.shift(at: cafe.id, 2026, 3, 2, from: 9, hours: 10),
            Fixtures.shift(at: cafe.id, 2026, 3, 3, from: 9, hours: 10),
            Fixtures.shift(at: cafe.id, 2026, 3, 4, from: 9, hours: 10),
            Fixtures.shift(at: pub.id, 2026, 3, 10, from: 12, hours: 12)
        ])

        let status = try useCase.execute(asOf: Fixtures.date(2026, 3, 11, at: 16))

        XCTAssertEqual(status.tightest.countedHours.value, 42, accuracy: 0.001)
        guard case .withinLimit(let remaining) = status.verdict else {
            return XCTFail("expected within limit, got \(status.verdict)")
        }
        XCTAssertEqual(remaining.value, 6, accuracy: 0.001)
    }

    func test_workLimitStatus_breaksHoursDownByVenueBusiestFirst() throws {
        let useCase = makeUseCase(recorded: [
            Fixtures.shift(at: cafe.id, 2026, 3, 9, from: 9, hours: 4),
            Fixtures.shift(at: pub.id, 2026, 3, 10, from: 17, hours: 9)
        ])

        let status = try useCase.execute(asOf: Fixtures.date(2026, 3, 11, at: 16))

        XCTAssertEqual(status.hoursByEmployer.count, 2)
        XCTAssertEqual(status.hoursByEmployer.first?.tradingName, "The Old Fitz")
        XCTAssertEqual(status.hoursByEmployer.first?.hours.value ?? 0, 9, accuracy: 0.001)
    }

    func test_workLimitStatus_fails_whenTermDatesDoNotCoverToday() {
        let useCase = makeUseCase(courseCalendar: CourseCalendar())

        XCTAssertThrowsError(try useCase.execute(asOf: Fixtures.date(2026, 3, 11, at: 16))) { error in
            XCTAssertEqual(error as? WorkLimitStatusError, .termDatesMissing)
        }
    }
}
