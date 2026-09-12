import Foundation

/// One venue the student works for, for example a cafe or a pub.
///
/// Employers roster independently and none of them sees the others' hours, so the app is the
/// only place the combined total exists. An employer is archived rather than deleted, because
/// past shifts still count toward past fortnights.
struct Employer: Identifiable, Hashable, Codable {
    let id: EmployerIdentifier
    var tradingName: String
    var isArchived: Bool

    init(id: EmployerIdentifier = EmployerIdentifier(),
         tradingName: String,
         isArchived: Bool = false) {
        self.id = id
        self.tradingName = tradingName
        self.isArchived = isArchived
    }
}
