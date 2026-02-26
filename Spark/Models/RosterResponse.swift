import Foundation

struct RosterResponse: Codable {
    let result: [Roster]
    let hasErrors: Bool
    let error: String?
}

struct Roster: Codable {
    let classRosterAttendeeID: Int
    let checkOutToo: Bool
    let classRosterID: Int
    let classRosterName: String
    let classDateTime: String
    let classStartTime: String
    let classEndTime: String
    let registeredContacts: [Contact]
    
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    var parsedDate: Date? {
        Self.isoFormatter.date(from: classDateTime)
    }
    
    var timeRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let startDate = formatter.date(from: classStartTime)
        let endDate = formatter.date(from: classEndTime)
        
        formatter.dateFormat = "hh:mm a"
        
        let startTimeString = startDate != nil ? formatter.string(from: startDate!) : ""
        let endTimeString = endDate != nil ? formatter.string(from: endDate!) : ""
        return "\(startTimeString) - \(endTimeString)"
    }
}

struct Contact: Codable {
    let name: String
    let image: String
    let contactId: Int
    let contactType: String
}
