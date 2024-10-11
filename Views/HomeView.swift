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
                    } else if let errorMessage = errorMessage {
                        Text("Hata: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        Text("Veriler alınıyor...")
                            .foregroundColor(.white)
                            .padding()
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
                            removeCityFromFavorites()
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
                            addCityToFavorites()
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

                    // Hata Mesajı (Eğer varsa)
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
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
                            displayedCity = selectedCity
                            fetchWeather(for: selectedCity)
                            fetchFiveDayWeather(for: selectedCity)
                            checkIfCityIsInFavorites(city: selectedCity)
                            showCitySearch = false
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
                                        selectedCity = city
                                        displayedCity = city
                                        fetchWeather(for: city)
                                        fetchFiveDayWeather(for: city)
                                        checkIfCityIsInFavorites(city: city)
                                        showMenu.toggle() // Menü kapat
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
                                displayedCity = "Mevcut Konum"
                                fetchWeatherForCurrentLocation()
                                showMenu.toggle()
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
                fetchWeatherForCurrentLocation()
                fetchFavoriteCities()
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

    // Şehri favorilerde kontrol eden fonksiyon
    func checkIfCityIsInFavorites(city: String) {
        if favoriteCities.contains(city) {
            isCityInFavorites = true
        } else {
            isCityInFavorites = false
        }
    }

    // Favori şehirden kaldırma işlemi
    func removeCityFromFavorites() {
        guard !selectedCity.isEmpty else {
            self.errorMessage = "Şehir seçilmedi."
            return
        }

        cityService.removeCityFromFavorites(city: selectedCity) { success in
            if success {
                print("Şehir favorilerden kaldırıldı.")
                fetchFavoriteCities()
                checkIfCityIsInFavorites(city: selectedCity)
            } else {
                self.errorMessage = "Şehir favorilerden kaldırılamadı."
            }
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

    // 5 günlük hava durumu verisini getir
    func fetchFiveDayWeather(for city: String) {
        weatherService.fetchFiveDayWeather(for: city) { result in
            switch result {
            case .success(let forecastData):
                self.fiveDayWeatherData = forecastData.list
            case .failure(let error):
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
                checkIfCityIsInFavorites(city: selectedCity)
            } else {
                self.errorMessage = "En fazla 5 şehir favorilere eklenebilir ya da şehir zaten eklenmiş."
            }
        }
    }
    


}
