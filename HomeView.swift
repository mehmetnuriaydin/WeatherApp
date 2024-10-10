import SwiftUI

struct HomeView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var weatherData: WeatherData?
    @State private var errorMessage: String?
    @State private var selectedCity: String = "" // Şehir adı için text field
    @State private var favoriteCities: [String] = [] // Favori şehirler listesi
    @State private var displayedCity: String = "Mevcut Konum" // Dinamik başlık
    private let cityService = CityService() // CityService entegrasyonu
    private let weatherService = WeatherService() // WeatherService entegrasyonu

    var body: some View {
        ZStack {
            backgroundColor(for: weatherData?.weather.first?.description ?? "")
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Başlık - Mevcut Konum veya Seçilen Şehir
                Text(displayedCity)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 50)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()

                // Şehir hava durumu
                if let weather = weatherData {
                    VStack(spacing: 10) {
                        Text("\(weather.main.temp, specifier: "%.1f")°C \(weatherEmoji(for: weather.weather.first?.description ?? ""))")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(weather.weather.first?.description.capitalized ?? "")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 40)
                } else if let errorMessage = errorMessage {
                    Text("Hata: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("Veriler alınıyor...")
                        .foregroundColor(.white)
                        .padding()
                }

                Spacer()

                // Şehir adı için TextField
                TextField("Şehir Gir", text: $selectedCity)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                // Şehre göre hava durumu getirme butonu
                Button(action: {
                    displayedCity = selectedCity // Şehir seçildiğinde başlığı güncelle
                    fetchWeather(for: selectedCity)
                }) {
                    Text("Şehir Hava Durumunu Getir")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                        .padding(.horizontal)
                }

                // Favorilere ekleme butonu
                Button(action: {
                    addCityToFavorites()
                }) {
                    Text("Favorilere Ekle")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.7)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                        .padding(.horizontal)
                }

                Spacer()

                // Favori şehirler listesi
                if !favoriteCities.isEmpty {
                    VStack(spacing: 10) {
                        Text("Favori Şehirler")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        // Favori şehirler listesi
                        ScrollView {
                            ForEach(favoriteCities, id: \.self) { city in
                                Button(action: {
                                    displayedCity = city // Favori şehir seçildiğinde başlığı güncelle
                                    fetchWeather(for: city)
                                }) {
                                    Text(city)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white.opacity(0.2))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .frame(height: 150)
                    }
                }

                // Mevcut konuma göre hava durumu butonu
                Button(action: {
                    displayedCity = "Mevcut Konum" // Mevcut konum seçildiğinde başlığı güncelle
                    fetchWeatherForCurrentLocation()
                }) {
                    Text("Mevcut Konuma Göre Hava Durumu")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            fetchFavoriteCities()
        }
    }

    // Arka plan için renk seçimi
    func backgroundColor(for condition: String) -> Color {
        switch condition.lowercased() {
        case "clear sky", "sunny":
            return Color.blue
        case "few clouds", "scattered clouds", "broken clouds", "cloudy":
            return Color.gray
        case "shower rain", "rain", "thunderstorm":
            return Color.blue.opacity(0.7)
        case "snow":
            return Color.white
        default:
            return Color.blue
        }
    }

    // Hava durumu için emoji/simge seçimi
    func weatherEmoji(for condition: String) -> String {
        switch condition.lowercased() {
        case "clear sky", "sunny":
            return "☀️"
        case "few clouds", "scattered clouds", "broken clouds", "cloudy":
            return "☁️"
        case "shower rain", "rain", "thunderstorm":
            return "🌧️"
        case "snow":
            return "❄️"
        default:
            return "🌍"
        }
    }

    // Mevcut konum için hava durumu verisini çeken fonksiyon
    func fetchWeatherForCurrentLocation() {
        guard let location = locationManager.location else {
            self.errorMessage = "Konum bilgisi mevcut değil."
            return
        }

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

    // Şehir adına göre hava durumu verisini getir
    func fetchWeather(for city: String) {
        weatherService.fetchWeather(for: city) { result in
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

    // Favori şehirleri Firestore'dan getir
    func fetchFavoriteCities() {
        cityService.getFavoriteCities { cities in
            if let cities = cities {
                self.favoriteCities = cities
            } else {
                print("Favori şehirler getirilemedi.")
            }
        }
    }

    // Şehir favorilere ekle
    func addCityToFavorites() {
        cityService.addCityToFavorites(city: selectedCity) { success in
            if success {
                print("Şehir favorilere eklendi.")
                fetchFavoriteCities()
            } else {
                print("Şehir favorilere eklenemedi.")
            }
        }
    }
}
