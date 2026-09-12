//
//  CountsTowardWorkLimitTests.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import XCTest
@testable import Clocked

/// The counting rules that date arithmetic gets wrong: midnight, and window edges.
final class CountsTowardWorkLimitTests: XCTestCase {

    private let cafe = Employer(tradingName: "Cafe Nord")

    private func window(from day: Int) -> FortnightWindow {
        FortnightWindow(firstDay: Fixtures.date(2026, 3, day), lengthInDays: 14, using: Fixtures.calendar)
    }

    func test_countedHours_splitsAnOvernightShiftAcrossBothDates() {
        // 10pm Friday to 6am Saturday. The course breaks from the Saturday, so only the two
        // hours before midnight count.
        let shift = Fixtures.shift(at: cafe.id, 2026, 3, 6, from: 22, hours: 8)
        let courseCalendar = Fixtures.semesterWithBreakFrom7March()

        let hours = shift.countedHours(in: window(from: 2),
                                       courseCalendar: courseCalendar,
                                       using: Fixtures.calendar)

        XCTAssertEqual(hours.value, 2, accuracy: 0.001)
    }

    func test_countedHours_countsOnlyTheHoursInsideTheWindow() {
        // Window 2 to 15 March. A shift on 16 March is outside it entirely.
        let shift = Fixtures.shift(at: cafe.id, 2026, 3, 16, from: 9, hours: 6)

        let hours = shift.countedHours(in: window(from: 2),
                                       courseCalendar: Fixtures.semester(),
                                       using: Fixtures.calendar)

        XCTAssertEqual(hours.value, 0, accuracy: 0.001)
    }

    func test_countedHours_areZeroForARequiredCoursePlacement() {
        let placement = Fixtures.shift(at: cafe.id, 2026, 3, 5, from: 9, hours: 8,
                                       engagementType: .requiredCoursePlacement)

        let hours = placement.countedHours(in: window(from: 2),
                                           courseCalendar: Fixtures.semester(),
                                           using: Fixtures.calendar)

        XCTAssertEqual(hours.value, 0, accuracy: 0.001)
    }
}
