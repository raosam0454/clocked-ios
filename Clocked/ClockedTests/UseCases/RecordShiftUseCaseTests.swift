//
//  RecordShiftUseCaseTests.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import XCTest
@testable import Clocked

final class RecordShiftUseCaseTests: XCTestCase {

    private let cafe = Employer(tradingName: "Cafe Nord")
    private let pub = Employer(tradingName: "The Old Fitz")

    private func makeUseCase(recorded: [WorkShift] = [],
                             employers: [Employer]? = nil) -> (RecordShiftUseCase, ShiftRepository) {
        let shifts = InMemoryShiftRepository(shifts: recorded)
        let useCase = RecordShiftUseCase(
            shiftRepository: shifts,
            employerRepository: InMemoryEmployerRepository(employers: employers ?? [cafe, pub]),
            studentID: Fixtures.student,
            calendar: Fixtures.calendar
        )
        return (useCase, shifts)
    }

    func test_recordShift_addsTheShiftToTheWorkRecord() throws {
        let (useCase, shifts) = makeUseCase()

        let shift = try useCase.execute(employerID: cafe.id,
                                        period: Fixtures.period(2026, 3, 5, from: 17, hours: 5))

        XCTAssertEqual(shifts.allShifts().count, 1)
        XCTAssertEqual(shift.scheduledDuration.value, 5, accuracy: 0.001)
        XCTAssertEqual(shift.recordedByStudentID, Fixtures.student)
    }

    func test_recordShift_fails_whenTheShiftHasNoHours() {
        let (useCase, _) = makeUseCase()
        let sameMoment = DateInterval(start: Fixtures.date(2026, 3, 5, at: 17), duration: 0)

        XCTAssertThrowsError(try useCase.execute(employerID: cafe.id, period: sameMoment)) { error in
            XCTAssertEqual(error as? ShiftRecordingError, .shiftHasNoHours)
        }
    }

    func test_recordShift_fails_whenTheShiftIsLongerThanADay() {
        let (useCase, _) = makeUseCase()
        let mistypedDates = Fixtures.period(2026, 3, 5, from: 9, hours: 30)

        XCTAssertThrowsError(try useCase.execute(employerID: cafe.id, period: mistypedDates)) { error in
            XCTAssertEqual(error as? ShiftRecordingError, .shiftLongerThanADay)
        }
    }

    func test_recordShift_fails_whenItOverlapsAShiftAtAnotherVenue() {
        let existing = Fixtures.shift(at: pub.id, 2026, 3, 5, from: 16, hours: 6)
        let (useCase, _) = makeUseCase(recorded: [existing])

        let clashing = Fixtures.period(2026, 3, 5, from: 18, hours: 4)

        XCTAssertThrowsError(try useCase.execute(employerID: cafe.id, period: clashing)) { error in
            XCTAssertEqual(error as? ShiftRecordingError,
                           .overlapsExistingShift(venue: "The Old Fitz"))
        }
    }

    func test_recordShift_allowsAShiftThatStartsWhenAnotherFinishes() throws {
        let morning = Fixtures.shift(at: cafe.id, 2026, 3, 5, from: 9, hours: 5)
        let (useCase, shifts) = makeUseCase(recorded: [morning])

        try useCase.execute(employerID: pub.id,
                            period: Fixtures.period(2026, 3, 5, from: 14, hours: 4))

        XCTAssertEqual(shifts.allShifts().count, 2)
    }

    func test_recordShift_fails_whenTheVenueIsNotInTheEmployerList() {
        let (useCase, _) = makeUseCase(employers: [])

        XCTAssertThrowsError(try useCase.execute(employerID: cafe.id,
                                                 period: Fixtures.period(2026, 3, 5, from: 17, hours: 5))) { error in
            XCTAssertEqual(error as? ShiftRecordingError, .employerNotRecognised)
        }
    }
}
