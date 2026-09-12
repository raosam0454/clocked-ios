import Foundation

/// Whether the course is running or on a scheduled break.
///
/// The work limit applies only while the course is in session. During a scheduled break there
/// is no limit, and students often miss that.
enum StudyMode: String, Codable {
    case inSession
    case courseBreak
}

/// A named stretch of the academic year, entered by the student from their course dates.
///
/// Both days are included: a period from 2 March to 15 March covers all of 15 March.
struct StudyPeriod: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var firstDay: Date
    var lastDay: Date
    var mode: StudyMode

    init(id: UUID = UUID(),
         name: String,
         firstDay: Date,
         lastDay: Date,
         mode: StudyMode) {
        self.id = id
        self.name = name
        self.firstDay = firstDay
        self.lastDay = lastDay
        self.mode = mode
    }

    /// Whether a date falls inside this period, comparing whole days only.
    func covers(_ date: Date, using calendar: Calendar) -> Bool {
        let day = calendar.startOfDay(for: date)
        return day >= calendar.startOfDay(for: firstDay)
            && day <= calendar.startOfDay(for: lastDay)
    }
}
