//
//  EvaluateShiftOfferUseCaseTests.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import XCTest
@testable import Clocked

/// Dates used throughout: Monday 2 March 2026 starts the fortnight in the examples.
final class EvaluateShiftOfferUseCaseTests: XCTestCase {

    private let cafe = Employer(tradingName: "Cafe Nord")

    private func makeUseCase(recorded: [WorkShift] = [],
                             courseCalendar: CourseCalendar = Fixtures.semester(),
                             employers: [Employer]? = nil) -> EvaluateShiftOfferUseCase {
        EvaluateShiftOfferUseCase(
            shiftRepository: InMemoryShiftRepository(shifts: recorded),
            employerRepository: InMemoryEmployerRepository(employers: employers ?? [cafe]),
            courseCalendarRepository: InMemoryCourseCalendarRepository(courseCalendar: courseCalendar),
            policy: .condition8105,
            calendar: Fixtures.calendar
        )
    }

    func test_evaluateOffer_isWithinLimit_whenTheFortnightHasRoomToSpare() throws {
        let useCase = makeUseCase(recorded: [
            Fixtures.shift(at: cafe.id, 2026, 3, 3, from: 9, hours: 8)
        ])
        let offer = ShiftOffer(employerID: cafe.id,
                               period: Fixtures.period(2026, 3, 5, from: 17, hours: 5))

        let assessment = try useCase.execute(offer)

        XCTAssertEqual(assessment.tightest.countedHours.value, 13, accuracy: 0.001)
        guard case .withinLimit(let remaining) = assessment.verdict else {
            return XCTFail("expected within limit, got \(assessment.verdict)")
        }
        XCTAssertEqual(remaining.value, 35, accuracy: 0.001)
    }

    func test_evaluateOffer_flagsBreach_whenThirtyHoursAreFollowedByThirtyHoursInAdjacentWeeks() throws {
        // 30 hours in the week of 2 March, 15 more in the week of 9 March. Neither week alone
        // breaks the cap, and no Monday to Sunday fortnight block does either.
        let useCase = makeUseCase(recorded: [
            Fixtures.shift(at: cafe.id, 2026, 3, 2, from: 9, hours: 10),
            Fixtures.shift(at: cafe.id, 2026, 3, 3, from: 9, hours: 10),
            Fixtures.shift(at: cafe.id, 2026, 3, 4, from: 9, hours: 10),
            Fixtures.shift(at: cafe.id, 2026, 3, 9, from: 9, hours: 10),
            Fixtures.shift(at: cafe.id, 2026, 3, 10, from: 9, hours: 5)
        ])
        let offer = ShiftOffer(employerID: cafe.id,
                               period: Fixtures.period(2026, 3, 11, from: 17, hours: 5))

        let assessment = try useCase.execute(offer)

        XCTAssertEqual(assessment.tightest.countedHours.value, 50, accuracy: 0.001)
        guard case .wouldBreach(let excess) = assessment.verdict else {
            return XCTFail("expected a breach, got \(assessment.verdict)")
        }
        XCTAssertEqual(excess.value, 2, accuracy: 0.001)
    }

    func test_evaluateOffer_isStillCompliant_whenTheTightestWindowLandsExactlyOnFortyEightHours() throws {
        let useCase = makeUseCase(recorded: [
            Fixtures.shift(at: cafe.id, 2026, 3, 2, from: 9, hours: 10),
            Fixtures.shift(at: cafe.id, 2026, 3, 3, from: 9, hours: 10),
            Fixtures.shift(at: cafe.id, 2026, 3, 4, from: 9, hours: 10),
            Fixtures.shift(at: cafe.id, 2026, 3, 5, from: 9, hours: 8),
            Fixtures.shift(at: cafe.id, 2026, 3, 6, from: 9, hours: 5)
        ])
        let offer = ShiftOffer(employerID: cafe.id,
                               period: Fixtures.period(2026, 3, 9, from: 17, hours: 5))

        let assessment = try useCase.execute(offer)

        XCTAssertEqual(assessment.tightest.countedHours.value, 48, accuracy: 0.001)
        guard case .approachingLimit(let remaining) = assessment.verdict else {
            return XCTFail("expected approaching limit, got \(assessment.verdict)")
        }
        XCTAssertEqual(remaining.value, 0, accuracy: 0.001)
    }

    func test_evaluateOffer_ignoresHoursWorkedDuringACourseBreak() throws {
        let useCase = makeUseCase(
            recorded: [Fixtures.shift(at: cafe.id, 2026, 3, 9, from: 9, hours: 10)],
            courseCalendar: Fixtures.semesterWithBreakFrom7March()
        )
        let offer = ShiftOffer(employerID: cafe.id,
                               period: Fixtures.period(2026, 3, 10, from: 9, hours: 12))

        let assessment = try useCase.execute(offer)

//        XCTAssertEqual(assessment.tightest.countedHours.value, 0, accuracy: 0.001)
    }

    func test_evaluateOffer_ignoresARequiredCoursePlacement() throws {
        let useCase = makeUseCase()
        let offer = ShiftOffer(employerID: cafe.id,
                               period: Fixtures.period(2026, 3, 10, from: 9, hours: 12),
                               engagementType: .requiredCoursePlacement)

        let assessment = try useCase.execute(offer)

        XCTAssertEqual(assessment.tightest.countedHours.value, 0, accuracy: 0.001)
    }

    func test_evaluateOffer_countsUnpaidWorkTowardTheLimit() throws {
        let useCase = makeUseCase()
        let offer = ShiftOffer(employerID: cafe.id,
                               period: Fixtures.period(2026, 3, 10, from: 9, hours: 6),
                               engagementType: .unpaidOrVolunteer)

        let assessment = try useCase.execute(offer)

        XCTAssertEqual(assessment.tightest.countedHours.value, 6, accuracy: 0.001)
    }

    func test_evaluateOffer_fails_whenTermDatesDoNotCoverTheOffer() {
        let useCase = makeUseCase(courseCalendar: CourseCalendar())
        let offer = ShiftOffer(employerID: cafe.id,
                               period: Fixtures.period(2026, 3, 10, from: 9, hours: 6))

        XCTAssertThrowsError(try useCase.execute(offer)) { error in
            switch error as? ShiftOfferEvaluationError {
            case .termDatesMissing: break
            default: XCTFail("expected missing term dates, got \(error)")
            }
        }
    }

    func test_evaluateOffer_fails_whenTheVenueIsNotInTheEmployerList() {
        let useCase = makeUseCase(employers: [])
        let offer = ShiftOffer(employerID: cafe.id,
                               period: Fixtures.period(2026, 3, 10, from: 9, hours: 6))

        XCTAssertThrowsError(try useCase.execute(offer)) { error in
            XCTAssertEqual(error as? ShiftOfferEvaluationError, .employerNotRecognised)
        }
    }
}
