import Foundation

@MainActor
final class RosterViewModel {
    
    private let apiClient: APIClientProtocol
    
    private(set) var rosters: [Roster] = []
    private(set) var filteredRosters: [Roster] = []
    
    var onLoadingStateChange: ((Bool) -> Void)?
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    /// Load cache first
    func loadCacheData() {
        if let cached: [Roster] = CacheManager.shared.load([Roster].self) {
            rosters = cached
            filteredRosters = cached
            onDataUpdated?()
        }
    }
    
    func fetchRosters(forceRefresh: Bool = false) async {
        
        if rosters.isEmpty {
            onLoadingStateChange?(true)
        }
        
        defer { onLoadingStateChange?(false) }
        
        do {
            let response: RosterResponse = try await apiClient.request(
                endpoint: .contacts,
                method: .GET,
                parameters: nil
            )
            
            self.rosters = response.result.sorted {
                ($0.parsedDate ?? .distantPast) < ($1.parsedDate ?? .distantPast)
            }
            
            self.filteredRosters = self.rosters
            CacheManager.shared.save(self.rosters)
            onDataUpdated?()
            
        } catch {
            onError?(error.localizedDescription)
        }
    }
    
    func filterRosters(searchText: String) {
        guard !searchText.isEmpty else {
            filteredRosters = rosters
            onDataUpdated?()
            return
        }
        
        filteredRosters = rosters.compactMap { roster in
            let matchingContacts = roster.registeredContacts.filter { contact in
                contact.name.localizedCaseInsensitiveContains(searchText) ||
                "\(contact.contactId)".contains(searchText)
            }
            
            let isClassNameMatch = roster.classRosterName.localizedCaseInsensitiveContains(searchText)
            
            let contactsToShow = isClassNameMatch ? roster.registeredContacts : matchingContacts
            
            guard isClassNameMatch || !matchingContacts.isEmpty else { return nil }
            
            return Roster(
                classRosterAttendeeID: roster.classRosterAttendeeID,
                checkOutToo: roster.checkOutToo,
                classRosterID: roster.classRosterID,
                classRosterName: roster.classRosterName,
                classDateTime: roster.classDateTime,
                classStartTime: roster.classStartTime,
                classEndTime: roster.classEndTime,
                registeredContacts: contactsToShow  // ✅ Correct contacts
            )
        }
        
        onDataUpdated?()
    }
}
