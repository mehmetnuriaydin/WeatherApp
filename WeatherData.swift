import Foundation

struct WeatherData: Codable {
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
    let humidity: Int // Nem oranı
}

struct Weather: Codable {
    let description: String
}
