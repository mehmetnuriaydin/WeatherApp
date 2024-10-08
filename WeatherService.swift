import Foundation

class WeatherService {
    let apiKey = "9d27b3ef69d310abe04244c1b5512901"
    // Şehir koordinatları kullanarak hava durumu verisi getirme
        func fetchWeather(forLatitude latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
            let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
            
            guard let url = URL(string: urlString) else {
                print("Geçersiz URL")
                completion(.failure(URLError(.badURL)))
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Veri çekme hatası: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    print("Sunucudan veri alınamadı.")
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }

                do {
                    let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(weatherData))
                    }
                } catch {
                    print("Veri decode hatası: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }.resume()
    }
}
