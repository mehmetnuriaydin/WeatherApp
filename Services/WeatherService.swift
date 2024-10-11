import Foundation

class WeatherService {
    let apiKey = "9d27b3ef69d310abe04244c1b5512901" // OpenWeatherMap API anahtarınızı ekleyin

    // Şehir adı kullanarak anlık hava durumu verisi getirme (async/await)
    func fetchWeather(for city: String) async throws -> WeatherData {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
        return weatherData
    }

    // Şehir koordinatları kullanarak hava durumu verisi getirme (async/await)
    func fetchWeather(forLatitude latitude: Double, longitude: Double) async throws -> WeatherData {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
        return weatherData
    }

    // 5 günlük hava durumu verisini getir (async/await)
    func fetchFiveDayWeather(for city: String) async throws -> FiveDayForecastResponse {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let forecastData = try JSONDecoder().decode(FiveDayForecastResponse.self, from: data)
        return forecastData
    }
}
