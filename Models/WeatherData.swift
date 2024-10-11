import Foundation

// 5 günlük hava durumu verisi için kullanılan genel yanıt modeli
struct FiveDayForecastResponse: Codable {
    let list: [WeatherData] // Her hava durumu kaydı
    let city: City? // Şehrin bilgileri, opsiyonel olabilir
}

struct City: Codable {
    let name: String?
}

// Tekil hava durumu kaydı
struct WeatherData: Codable {
    let main: Main
    let weather: [Weather]
    let wind: Wind? // Rüzgar bilgisi opsiyonel olabilir
    let dt_txt: String? // Tarih ve saat bilgisi, opsiyonel olabilir
}

struct Main: Codable {
    let temp: Double
    let humidity: Int // Nem oranı
}

struct Weather: Codable {
    let description: String
}

struct Wind: Codable {
    let speed: Double? // Rüzgar hızı opsiyonel olabilir
}
