import Foundation

struct LaunchListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Launch]
}

struct Launch: Codable, Identifiable {
    let id: String
    let url: String
    let name: String
    let status: LaunchStatus?
    let net: Date?
    let windowEnd: Date?
    let windowStart: Date?
    let rocket: Rocket?
    let mission: Mission?
    let pad: Pad?
    let image: String?
    let launchServiceProvider: LaunchServiceProvider? // newly added
    
    enum CodingKeys: String, CodingKey {
        case id, url, name, status, net
        case windowEnd = "window_end"
        case windowStart = "window_start"
        case rocket, mission, pad, image
        case launchServiceProvider = "launch_service_provider"
    }
}

struct LaunchServiceProvider: Codable {
    let id: Int
    let name: String
    let logoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case logoUrl = "logo_url"
    }
}

struct LaunchStatus: Codable {
    let id: Int
    let name: String
    let abbrev: String?
    let description: String?
}

struct Rocket: Codable {
    let id: Int
    let configuration: RocketConfiguration?
}

struct RocketConfiguration: Codable {
    let id: Int
    let name: String
    let family: String?
    let fullName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, family
        case fullName = "full_name"
    }
}

struct Mission: Codable {
    let id: Int
    let name: String
    let description: String?
    let type: String?
    let orbit: Orbit?
}

struct Orbit: Codable {
    let id: Int
    let name: String
    let abbrev: String
}

struct Pad: Codable {
    let id: Int
    let name: String
    let latitude: String?
    let longitude: String?
    let location: Location?
}

struct Location: Codable {
    let id: Int
    let name: String
    let countryCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case countryCode = "country_code"
    }
}
