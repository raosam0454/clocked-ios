import Foundation

/// Identifies one employer.
///
/// Wrapped in its own type so an employer id cannot be passed where a shift id is expected.
struct EmployerIdentifier: Hashable, Codable {
    let value: UUID

    init(_ value: UUID = UUID()) {
        self.value = value
    }
}

/// Identifies one shift in the work record.
struct ShiftIdentifier: Hashable, Codable {
    let value: UUID

    init(_ value: UUID = UUID()) {
        self.value = value
    }
}

/// Identifies the student whose work record this is.
///
/// Every shift records who logged it, so the record can be exported as evidence later.
struct StudentIdentifier: Hashable, Codable {
    let value: UUID

    init(_ value: UUID = UUID()) {
        self.value = value
    }
}
