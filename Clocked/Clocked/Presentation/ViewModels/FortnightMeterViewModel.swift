//
//  FortnightMeterViewModel.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import Foundation
import Observation

/// How close to the limit the meter is, for colour and wording.
enum MeterTone {
    case safe
    case warning
    case breach
}

/// Screen state for the fortnight meter.
///
/// Holds no business rules. It asks the use case for the answer and turns domain values into
/// strings the view can draw, which is the only job a view model has here.
@MainActor
@Observable
final class FortnightMeterViewModel {
    private let calculateStatus: CalculateWorkLimitStatusUseCase
    private let capHours = StudentVisaWorkLimitPolicy.condition8105.capHours
    private let now: () -> Date

    private(set) var status: WorkLimitStatus?
    private(set) var problem: String?

    init(dependencies: AppDependencies, now: @escaping () -> Date = { Date() }) {
        self.calculateStatus = dependencies.makeCalculateWorkLimitStatusUseCase()
        self.now = now
    }

    func refresh() {
        do {
            status = try calculateStatus.execute(asOf: now())
            problem = nil
        } catch {
            status = nil
            problem = error.localizedDescription
        }
    }

    var hoursUsedText: String {
        format(status?.tightest.countedHours ?? .zero)
    }

    var capText: String {
        format(capHours)
    }

    var remainingText: String {
        switch status?.verdict {
        case .withinLimit(let remaining), .approachingLimit(let remaining):
            return "\(format(remaining)) hours left this fortnight"
        case .wouldBreach(let excess):
            return "\(format(excess)) hours over the limit"
        case .none:
            return ""
        }
    }

    var windowText: String {
        guard let window = status?.tightest.window else { return "" }
        let first = window.firstDay.formatted(.dateTime.day().month(.abbreviated))
        let last = window.lastDay.formatted(.dateTime.day().month(.abbreviated))
        return "Tightest fortnight \(first) to \(last)"
    }

    var interpretationText: String {
        guard let name = status?.interpretationName else { return "" }
        return "Counted using \(name). Not legal advice."
    }

    var employers: [EmployerHours] {
        status?.hoursByEmployer ?? []
    }

    /// How full the meter is, capped at 1 so a breach does not overflow the bar.
    var fillFraction: Double {
        guard let hours = status?.tightest.countedHours.value, capHours.value > 0 else { return 0 }
        return min(hours / capHours.value, 1)
    }

    var tone: MeterTone {
        switch status?.verdict {
        case .approachingLimit: return .warning
        case .wouldBreach: return .breach
        default: return .safe
        }
    }

    private func format(_ hours: WorkedHours) -> String {
        hours.value.formatted(.number.precision(.fractionLength(0...1)))
    }
}
