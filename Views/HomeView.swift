import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var weatherData: WeatherData?
    @State private var errorMessage: String?
    @State private var selectedCity: String = "" // Şehir adı için
    @State private var favoriteCities: [String] = [] // Favori şehirler listesi
    @State private var displayedCity: String = "Mevcut Konum" // Dinamik başlık
    @State private var showCitySearch = false // Şehir arama sayfasını göstermek için
    @State private var showMenu = false // Menü açma/kapatma kontrolü
    @State private var fiveDayWeatherData: [WeatherData] = [] // 5 günlük hava durumu
    @State private var isCityInFavorites: Bool = false // Şehrin favorilerde olup olmadığını kontrol etmek için
    @State private var isLoggedOut = false // Oturum kapatma durumu
    private let cityService = CityService() // CityService entegrasyonu
    private let weatherService = WeatherService() // WeatherService entegrasyonu

    var body: some View {
        if isLoggedOut {
            LoginView() // Oturum kapandıysa giriş ekranına dön
        } else {
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

                    // ANLIK HAVA DURUMU
                    if let weather = weatherData {
                        VStack(spacing: 10) {
                            // Sıcaklık bilgisi ve duruma göre emoji
                            Text("\(Int(weather.main.temp))°C \(weatherEmoji(for: weather.weather.first?.description ?? ""))")
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(.white)

                            // Hava durumu açıklamasını Türkçeye çevirerek gösterelim
                            Text(translateWeatherCondition(weather.weather.first?.description ?? ""))
                                .font(.title)
                                .foregroundColor(.white)

                            // Eklenen Nem ve Rüzgar Hızı bilgileri
                            HStack {
                                Text("Nem: \(weather.main.humidity)%")
                                    .foregroundColor(.white)
                                    .font(.title2)

                                Text("Rüzgar: \(weather.wind?.speed ?? 0, specifier: "%.1f") m/s")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                            .padding(.top, 10)
                        }
                        .padding(.bottom, 40)
                    } else {
                        VStack {
                            if let errorMessage = errorMessage {
                                // Mevcut konumu al butonu
                                VStack {
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                        .padding(.bottom, 10)

                                    Button(action: {
                                        Task {
                                            await fetchWeatherForCurrentLocation()
                                        }
                                    }) {
                                        Text("Mevcut konumu almak için tıklayınız")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.blue)
                                            .cornerRadius(15)
                                            .padding(.horizontal)
                                    }
                                }
                            } else {
                                Text("Veriler alınıyor...")
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                    }

                    // 5 GÜNLÜK HAVA DURUMU TAHMİNİ
                    if !fiveDayWeatherData.isEmpty {
                        let columns = Array(repeating: GridItem(.flexible(), spacing: 30), count: 5)

                        LazyVGrid(columns: columns, spacing: 30) {
                            ForEach(fiveDayWeatherData.prefix(5), id: \.dt_txt) { weather in
                                VStack {
                                    // Emoji ile hava durumu gösterimi
                                    Text(weatherEmoji(for: weather.weather.first?.description ?? ""))
                                        .font(.system(size: 40))
                                        .frame(width: 40, height: 40)
                                        .background(Color.clear)
                                        .cornerRadius(30)
                                        .padding(.bottom, 10)

                                    // Sıcaklık
                                    Text("\(Int(weather.main.temp))°C")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.bottom, 5)

                                    // Gün (dt_txt'den gün ismini çıkarıyoruz)
                                    if let date = weather.dt_txt {
                                        let formattedDay = formatDay(from: date)
                                        Text(formattedDay)
                                            .font(.footnote)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(15)
                                .frame(width: 70, height: 180)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer()

                    // Favori Şehir Butonu: Favorilerdeyse kaldırma butonu, değilse ekleme butonu
                    if isCityInFavorites {
                        Button(action: {
                            Task {
                                await removeCityFromFavorites()
                            }
                        }) {
                            Text("Şehri Favorilerden Kaldır")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(15)
                                .padding(.horizontal)
                        }
                    } else {
                        Button(action: {
                            Task {
                                await addCityToFavorites()
                            }
                        }) {
                            Text("Şehri Favoriye Ekle")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(15)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showMenu.toggle() // Menü açma/kapatma
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(.white)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showCitySearch.toggle()
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                        }
                    }
                }
                .sheet(isPresented: $showCitySearch) {
                    VStack {
                        Text("Şehir Ara")
                            .font(.headline)
                            .padding()

                        TextField("Şehir Adı", text: $selectedCity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding()

                        Button("Ara", action: {
                            Task {
                                displayedCity = selectedCity
                                await fetchWeather(for: selectedCity)
                                await fetchFiveDayWeather(for: selectedCity)
                                await checkIfCityIsInFavorites(city: selectedCity)
                                showCitySearch = false
                            }
                        })
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)

                        Spacer()
                    }
                    .padding()
                }

                // Favori Şehirler Menü
                if showMenu {
                    HStack {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Favori Şehirler")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.top, 50)

                            ScrollView {
                                ForEach(favoriteCities, id: \.self) { city in
                                    Button(action: {
                                        Task {
                                            selectedCity = city
                                            displayedCity = city
                                            await fetchWeather(for: city)
                                            await fetchFiveDayWeather(for: city)
                                            await checkIfCityIsInFavorites(city: city)
                                            showMenu.toggle() // Menü kapat
                                        }
                                    }) {
                                        Text(city)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.white.opacity(0.2))
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            Spacer()

                            // Mevcut konuma göre hava durumu butonu
                            Button(action: {
                                Task {
                                    displayedCity = "Mevcut Konum"
                                    await fetchWeatherForCurrentLocation()
                                    showMenu.toggle()
                                }
                            }) {
                                Text("Mevcut Konuma Göre Hava Durumu")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(15)
                                    .padding(.horizontal)
                            }

                            // Çıkış Yap butonu
                            Button(action: {
                                logOut() // Oturum kapatma işlemi
                            }) {
                                Text("Çıkış Yap")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .cornerRadius(15)
                                    .padding(.horizontal)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .frame(width: 250)

                        Spacer()
                    }
                    .transition(.move(edge: .leading))
                }
            }
            .onAppear {
                Task {
                    await fetchWeatherForCurrentLocation()
                    await fetchFavoriteCities()
                }
            }
        }
    }

    // Günü formatlayan fonksiyon
    func formatDay(from dateText: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let date = dateFormatter.date(from: dateText) {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            return dayFormatter.string(from: date)
        }
        return dateText
    }

    // Şehri favorilerde kontrol eden fonksiyon (async/await)
    func checkIfCityIsInFavorites(city: String) async {
        do {
            if let cities = try await cityService.getFavoriteCities() {
                favoriteCities = cities
                isCityInFavorites = favoriteCities.contains(city)
            }
        } catch {
            errorMessage = "Favori şehirler alınamadı: \(error.localizedDescription)"
        }
    }

    // Favori şehirden kaldırma işlemi (async/await)
    func removeCityFromFavorites() async {
        guard !selectedCity.isEmpty else {
            self.errorMessage = "Şehir seçilmedi."
            return
        }

        do {
            let success = try await cityService.removeCityFromFavorites(city: selectedCity)
            if success {
                print("Şehir favorilerden kaldırıldı.")
                await fetchFavoriteCities()
                await checkIfCityIsInFavorites(city: selectedCity)
            } else {
                self.errorMessage = "Şehir favorilerden kaldırılamadı."
            }
        } catch {
            self.errorMessage = "Favori şehir kaldırılamadı: \(error.localizedDescription)"
        }
    }

    // Favori şehir ekleme işlemi (async/await)
    func addCityToFavorites() async {
        do {
            let success = try await cityService.addCityToFavorites(city: selectedCity)
            if success {
                print("Şehir favorilere eklendi.")
                await fetchFavoriteCities()
                await checkIfCityIsInFavorites(city: selectedCity)
            } else {
                self.errorMessage = "En fazla 5 şehir favorilere eklenebilir ya da şehir zaten eklenmiş."
            }
        } catch {
            self.errorMessage = "Favori şehir eklenemedi: \(error.localizedDescription)"
        }
    }

    // Çıkış yapma fonksiyonu
    func logOut() {
        do {
            try Auth.auth().signOut() // Firebase'den çıkış yap
            isLoggedOut = true // Ekranı LoginView'e yönlendir
        } catch {
            self.errorMessage = "Çıkış yapılamadı: \(error.localizedDescription)"
        }
    }

    // Mevcut konum için hava durumu verisini çeken fonksiyon (async/await)
    func fetchWeatherForCurrentLocation() async {
        guard let location = locationManager.location else {
            self.errorMessage = "Konum bilgisi mevcut değil."
            return
        }

        do {
            weatherData = try await weatherService.fetchWeather(forLatitude: location.latitude, longitude: location.longitude)
            errorMessage = nil
        } catch {
            weatherData = nil
            errorMessage = error.localizedDescription
        }
    }

    // Şehir adına göre hava durumu verisini getir (async/await)
    func fetchWeather(for city: String) async {
        do {
            weatherData = try await weatherService.fetchWeather(for: city)
            errorMessage = nil
        } catch {
            weatherData = nil
            errorMessage = error.localizedDescription
        }
    }

    // 5 günlük hava durumu verisini getir (async/await)
    func fetchFiveDayWeather(for city: String) async {
        do {
            let forecastData = try await weatherService.fetchFiveDayWeather(for: city)
            fiveDayWeatherData = forecastData.list
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Favori şehirleri Firestore'dan getir (async/await)
    func fetchFavoriteCities() async {
        do {
            if let cities = try await cityService.getFavoriteCities() {
                favoriteCities = cities
            } else {
                errorMessage = "Favori şehirler getirilemedi."
            }
        } catch {
            errorMessage = "Favori şehirler alınamadı: \(error.localizedDescription)"
        }
    }

    // Hava durumu için arka plan rengi
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

    // Hava durumu için emoji seçimi
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
}
