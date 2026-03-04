import Foundation

class SpaceDevsAPI {
    static let shared = SpaceDevsAPI()
    
    // For development/testing, we should probably use the dev API, but ll.thespacedevs.com/2.2.0 is the production one.
    // The dev URL is "https://lldev.thespacedevs.com/2.2.0/launch/upcoming/" which doesn't require auth but might be delayed.
    // We'll use the production URL which allows 15 requests per hour unauthenticated.
    private let baseURL = "https://ll.thespacedevs.com/2.2.0"
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    func fetchUpcomingLaunches() async throws -> [Launch] {
        guard let url = URL(string: "\(baseURL)/launch/upcoming/?limit=20") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 429 {
                print("Rate limited by Space Devs API")
            }
            throw URLError(.badServerResponse)
        }
        
        let launchList = try decoder.decode(LaunchListResponse.self, from: data)
        return launchList.results
    }
}
