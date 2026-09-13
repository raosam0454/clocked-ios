//
//  ShiftOfferCheckViewModel.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import Foundation
import Observation

/// One fortnight window as the student sees it.
struct AffectedWindowRow: Identifiable {
    let id: Date
    let range: String
    let hours: String
    let tone: MeterTone
}

/// Screen state for "can I take this shift?".
///
/// The form is deliberately short. A cover request gives the student minutes, so venue, day,
/// start time and length are all that is asked for.
@MainActor
@Observable
final class ShiftOfferCheckViewModel {
    private let evaluate: EvaluateShiftOfferUseCase
    private let record: RecordShiftUseCase
    private let employerRepository: EmployerRepository
    private let capHours = StudentVisaWorkLimitPolicy.condition8105.capHours

    var employerID: EmployerIdentifier?
    var startsAt: Date
    var lengthInHours: Double = 5
    var engagementType: WorkEngagementType = .paid

    private(set) var assessment: WorkLimitAssessment?
    private(set) var problem: String?
    private(set) var confirmation: String?

    init(dependencies: AppDependencies, now: Date = Date()) {
        self.evaluate = dependencies.makeEvaluateShiftOfferUseCase()
        self.record = dependencies.makeRecordShiftUseCase()
        self.employerRepository = dependencies.employerRepository
        self.startsAt = now
        self.employerID = dependencies.employerRepository.allEmployers().first?.id
    }

    var employers: [Employer] {
        employerRepository.allEmployers().filter { !$0.isArchived }
    }

    private var offer: ShiftOffer? {
        guard let employerID else { return nil }
        return ShiftOffer(employerID: employerID,
                          period: DateInterval(start: startsAt, duration: lengthInHours * 3600),
                          engagementType: engagementType)
    }

    func check() {
        confirmation = nil
        guard let offer else {
            problem = "Choose which venue the shift is at."
            return
        }
        do {
            assessment = try evaluate.execute(offer)
            problem = nil
        } catch {
            assessment = nil
            problem = error.localizedDescription
        }
    }

    /// Saves the shift the student decided to take, so the next answer includes it.
    func accept() {
        guard let offer else { return }
        do {
            try record.execute(employerID: offer.employerID,
                               period: offer.period,
                               engagementType: offer.engagementType)
            confirmation = "Saved to your work record."
            assessment = nil
            problem = nil
        } catch {
            problem = error.localizedDescription
        }
    }

    // MARK: - Wording

    var headline: String {
        switch assessment?.verdict {
        case .withinLimit: return "You can take this shift"
        case .approachingLimit: return "You can take it, but only just"
        case .wouldBreach: return "Taking this would put you over"
        case .none: return ""
        }
    }

    var detail: String {
        switch assessment?.verdict {
        case .withinLimit(let remaining):
            return "\(format(remaining)) hours would still be left in your tightest fortnight."
        case .approachingLimit(let remaining):
            return "Only \(format(remaining)) hours would be left. One more shift would break the limit."
        case .wouldBreach(let excess):
            return "It would put you \(format(excess)) hours over the 48 hour limit in an overlapping fortnight."
        case .none:
            return ""
        }
    }

    var tone: MeterTone {
        switch assessment?.verdict {
        case .approachingLimit: return .warning
        case .wouldBreach: return .breach
        default: return .safe
        }
    }

    var interpretationText: String {
        guard let name = assessment?.interpretationName else { return "" }
        return "Counted using \(name). Not legal advice."
    }

    /// The three fullest fortnights this shift touches. All fourteen would be noise, and only
    /// the fullest ones change the answer.
    var tightestWindows: [AffectedWindowRow] {
        guard let assessment else { return [] }
        return assessment.windows
            .sorted { $0.countedHours > $1.countedHours }
            .prefix(3)
            .map { entry in
                AffectedWindowRow(
                    id: entry.window.firstDay,
                    range: "\(entry.window.firstDay.formatted(.dateTime.day().month(.abbreviated))) to "
                         + "\(entry.window.lastDay.formatted(.dateTime.day().month(.abbreviated)))",
                    hours: "\(format(entry.countedHours)) / \(format(capHours))",
                    tone: tone(for: entry.verdict)
                )
            }
    }

    private func tone(for verdict: ComplianceVerdict) -> MeterTone {
        switch verdict {
        case .withinLimit: return .safe
        case .approachingLimit: return .warning
        case .wouldBreach: return .breach
        }
    }

    private func format(_ hours: WorkedHours) -> String {
        hours.value.formatted(.number.precision(.fractionLength(0...1)))
    }
}
