import Foundation

class User: ObservableObject, Codable {

    enum CodingKeys: CodingKey {
        case username, userEmail
    }
    
    @Published var username: String = ""
    @Published var userEmail: String = ""

    init() {
        if let data = UserDefaults.standard.data(forKey: "UserData") {
            if let decoded = try? JSONDecoder().decode(User.self, from: data) {
                self.username = decoded.username
                self.userEmail = decoded.userEmail
                return
            }
        }
        // If no saved data, initialize with default values.
        self.username = ""
        self.userEmail = ""
    }
    
    func save() {
           do {
               let data = try JSONEncoder().encode(self)
               UserDefaults.standard.set(data, forKey: "UserData")
           } catch {
               print("Failed to save user data: \(error)")
           }
       }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(userEmail, forKey: .userEmail)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
        userEmail = try container.decode(String.self, forKey: .userEmail)
    }
    
}
