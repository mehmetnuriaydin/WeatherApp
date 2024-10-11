import FirebaseFirestore
import FirebaseAuth

class CityService {
    // Firestore veritabanı referansı
    private let db = Firestore.firestore()

    // Firebase'den o anki kullanıcının UID'sini al
    private let user = Auth.auth().currentUser

    // Kullanıcının favori şehirlerini Firestore'dan getir (async/await)
    func getFavoriteCities() async throws -> [String]? {
        guard let userId = user?.uid else {
            throw URLError(.badURL)
        }

        let docRef = db.collection("users").document(userId)
        let document = try await docRef.getDocument()

        if let data = document.data() {
            let favorites = data["favorites"] as? [String]
            return favorites
        } else {
            return nil
        }
    }

    // Şehirleri favorilere ekle (async/await)
    func addCityToFavorites(city: String) async throws -> Bool {
        guard let userId = user?.uid else {
            throw URLError(.badURL)
        }

        let docRef = db.collection("users").document(userId)
        let document = try await docRef.getDocument()

        var favorites = document.data()?["favorites"] as? [String] ?? []

        if favorites.count < 5, !favorites.contains(city) {
            favorites.append(city)
            try await docRef.updateData(["favorites": favorites])
            return true
        } else {
            print("En fazla 5 şehir favorilere eklenebilir ya da şehir zaten eklenmiş.")
            return false
        }
    }

    // Şehri favorilerden kaldır (async/await)
    func removeCityFromFavorites(city: String) async throws -> Bool {
        guard let userId = user?.uid else {
            throw URLError(.badURL)
        }

        let docRef = db.collection("users").document(userId)
        let document = try await docRef.getDocument()

        var favorites = document.data()?["favorites"] as? [String] ?? []

        if let index = favorites.firstIndex(where: { $0.caseInsensitiveCompare(city) == .orderedSame }) {
            favorites.remove(at: index)
            try await docRef.updateData(["favorites": favorites])
            return true
        } else {
            print("Şehir favorilerde bulunamadı.")
            return false
        }
    }
}
