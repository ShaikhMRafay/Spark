import Foundation

struct Constants {

    struct App {
        static let appName = "Spark"
    }
    
    struct API {
        static let baseURL = "https://api.mockfly.dev/mocks/1f7f7b81-4043-4b86-bb26-7671dc92434d/"
        static let timeout: TimeInterval = 30.0
    }
    
    enum Endpoints: Equatable {
        case contacts
        
        var path: String {
            switch self {
            case .contacts: return "contacts"
            }
        }
        
        var url: String {
            return Constants.API.baseURL + path
        }
    }
}
