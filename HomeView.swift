import SwiftUI

struct HomeView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var weatherData: WeatherData?
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let location = locationManager.location {
                Text("Current Location: \(location.latitude), \(location.longitude)")
                    .padding()
                
                if let weather = weatherData {
                    Text("Sıcaklık: \(weather.main.temp)°C")
                        .font(.largeTitle)
                        .padding()

                    Text("Durum: \(weather.weather.first?.description ?? "")")
                        .font(.title2)
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("Hava durumu verisi alınamadı.")
                        .padding()
                }
            } else {
                Text("Konum verisi alınamadı.")
                    .padding()
            }

            Button(action: {
                fetchWeatherForCurrentLocation()
            }) {
                Text("Mevcut Konuma Göre Hava Durumu")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }

    // Mevcut konum için hava durumu verisini çeken fonksiyon
    func fetchWeatherForCurrentLocation() {
        guard let location = locationManager.location else {
            self.errorMessage = "Konum bilgisi mevcut değil."
            return
        }
        
        // Koordinatları al
        let latitude = location.latitude
        let longitude = location.longitude
        
        // Koordinatlara göre hava durumu verisini al
        WeatherService().fetchWeather(forLatitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let data):
                self.weatherData = data
                self.errorMessage = nil
            case .failure(let error):
                self.weatherData = nil
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
