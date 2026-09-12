//
//  ShiftRepository.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import Foundation

/// Where recorded shifts are kept.
protocol ShiftRepository: AnyObject {
    func allShifts() -> [WorkShift]
    func add(_ shift: WorkShift)
}

/// Shifts held in memory for the life of the app session.
///
/// A class, not a struct: several screens read and write the same list, and they must see each
/// other's changes. Storage that survives a restart replaces this later, behind the same
/// protocol.
final class InMemoryShiftRepository: ShiftRepository {
    private var shifts: [WorkShift]

    init(shifts: [WorkShift] = []) {
        self.shifts = shifts
    }

    func allShifts() -> [WorkShift] {
        shifts
    }

    func add(_ shift: WorkShift) {
        shifts.append(shift)
    }
}
