//
//  ExportWorkRecordUseCaseTests.swift
//  Clocked
//
//  Created by Sumangala Rao on 10/9/2026.
//
import XCTest
@testable import Clocked

final class ExportWorkRecordUseCaseTests: XCTestCase {

    private let cafe = Employer(tradingName: "Cafe Nord")

    private func makeUseCase(recorded: [WorkShift],
                             courseCalendar: CourseCalendar = Fixtures.semester()) -> ExportWorkRecordUseCase {
        ExportWorkRecordUseCase(
            shiftRepository: InMemoryShiftRepository(shifts: recorded),
            employerRepository: InMemoryEmployerRepository(employers: [cafe]),
            courseCalendarRepository: InMemoryCourseCalendarRepository(courseCalendar: courseCalendar),
            policy: .condition8105,
            calendar: Fixtures.calendar
        )
    }

    func test_exportWorkRecord_namesTheVenueAndTheHoursForEveryShift() throws {
        let useCase = makeUseCase(recorded: [
            Fixtures.shift(at: cafe.id, 2026, 3, 5, from: 9, hours: 8)
        ])

        let export = try useCase.execute(asOf: Fixtures.date(2026, 3, 11, at: 16))

        XCTAssertTrue(export.text.contains("Cafe Nord"))
        XCTAssertTrue(export.text.contains("8h worked"))
        XCTAssertTrue(export.text.contains("8h counted"))
    }

    func test_exportWorkRecord_marksCourseBreakHoursAsNotCounted() throws {
        let useCase = makeUseCase(
            recorded: [Fixtures.shift(at: cafe.id, 2026, 3, 10, from: 9, hours: 8)],
            courseCalendar: Fixtures.semesterWithBreakFrom7March()
        )

        let export = try useCase.execute(asOf: Fixtures.date(2026, 3, 11, at: 16))

        XCTAssertTrue(export.text.contains("not counted toward the limit"))
    }

    func test_exportWorkRecord_statesThatHoursAreSelfReported() throws {
        let useCase = makeUseCase(recorded: [
            Fixtures.shift(at: cafe.id, 2026, 3, 5, from: 9, hours: 8)
        ])

        let export = try useCase.execute(asOf: Fixtures.date(2026, 3, 11, at: 16))

        XCTAssertTrue(export.text.contains("entered by the student"))
    }

    func test_exportWorkRecord_fails_whenNoShiftsHaveBeenRecorded() {
        let useCase = makeUseCase(recorded: [])

        XCTAssertThrowsError(try useCase.execute(asOf: Fixtures.date(2026, 3, 11, at: 16))) { error in
            XCTAssertEqual(error as? WorkRecordExportError, .noShiftsRecorded)
        }
    }
}
