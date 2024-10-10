import FirebaseFirestore
import FirebaseAuth

class CityService {
    // Firestore veritabanı referansı
    private let db = Firestore.firestore()

    // Firebase'den o anki kullanıcının UID'sini al
    private let user = Auth.auth().currentUser

    // Kullanıcının favori şehirlerini Firestore'dan getir
    func getFavoriteCities(completion: @escaping ([String]?) -> Void) {
        guard let userId = user?.uid else {
            completion(nil)
            return
        }

        let docRef = db.collection("users").document(userId)

        // Firestore'dan kullanıcı belgesini getir
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                // "favorites" alanını array olarak oku
                let favorites = data?["favorites"] as? [String]
                completion(favorites)
            } else {
                print("Favoriler alınamadı: \(error?.localizedDescription ?? "Bilinmeyen hata")")
                completion(nil)
            }
        }
    }

    // Şehirleri favorilere ekle
    func addCityToFavorites(city: String, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false)
            return
        }

        let docRef = db.collection("users").document(userId)

        // Mevcut favori şehirler dizisini getir
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var favorites = document.data()?["favorites"] as? [String] ?? []
                
                // Eğer favori şehir sayısı 5'ten az ve bu şehir zaten eklenmemişse ekle
                if favorites.count < 5, !favorites.contains(city) {
                    favorites.append(city)
                    docRef.updateData(["favorites": favorites]) { error in
                        if let error = error {
                            print("Favori şehir eklenemedi: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Şehir başarıyla favorilere eklendi.")
                            completion(true)
                        }
                    }
                } else {
                    // Eğer favori şehir zaten ekli ise ya da limit aşılmışsa hata mesajı
                    print("En fazla 5 şehir favorilere eklenebilir ya da şehir zaten eklenmiş.")
                    completion(false)
                }
            } else {
                // Eğer belge yoksa yeni bir belge oluştur ve favori şehri ekle
                docRef.setData(["favorites": [city]]) { error in
                    if let error = error {
                        print("Favori şehirler oluşturulamadı: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Yeni favori şehir listesi oluşturuldu ve şehir eklendi.")
                        completion(true)
                    }
                }
            }
        }
    }

    // Şehri favorilerden kaldır
    func removeCityFromFavorites(city: String, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false)
            return
        }

        let docRef = db.collection("users").document(userId)

        // Mevcut favori şehirler dizisini getir
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var favorites = document.data()?["favorites"] as? [String] ?? []
                
                // Şehir favorilerde varsa kaldır
                if let index = favorites.firstIndex(of: city) {
                    favorites.remove(at: index)
                    docRef.updateData(["favorites": favorites]) { error in
                        if let error = error {
                            print("Şehir favorilerden kaldırılamadı: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Şehir favorilerden başarıyla kaldırıldı.")
                            completion(true)
                        }
                    }
                } else {
                    print("Şehir favorilerde bulunamadı.")
                    completion(false)
                }
            } else {
                print("Kullanıcı belgesi bulunamadı.")
                completion(false)
            }
        }
    }
}
