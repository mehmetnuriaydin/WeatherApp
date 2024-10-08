import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var weatherData: WeatherData?
    @State private var errorMessage: String?
    
    var weatherService = WeatherService()
    
    var body: some View {
        VStack {
            if let location = locationManager.location {
                Text("Current Location: \(location.latitude), \(location.longitude)")
                
                if let weather = weatherData {
                    VStack {
                        Text("Temperature: \(weather.main.temp)°C")
                        Text("Humidity: \(weather.main.humidity)%")
                        Text("Condition: \(weather.weather.first?.description ?? "")")
                    }
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                } else {
                    Text("No weather data available.")
                }
            } else {
                Text("Fetching location...")
            }
            
            Button("Fetch Weather for Current Location") {
                fetchWeather()
            }
        }
        .padding()
        .onAppear {
            fetchWeather()
        }
    }
    
    private func fetchWeather() {
        guard let location = locationManager.location else {
            self.errorMessage = "Location not available."
            return
        }

        // Koordinatlar ile hava durumu verisini getirme
        weatherService.fetchWeather(forLatitude: location.latitude, longitude: location.longitude) { result in
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
