
# WeatherApp

WeatherApp, SwiftUI ile geliştirilmiş bir hava durumu uygulamasıdır. Gerçek zamanlı hava durumu verilerini sağlar ve kullanıcıların favori şehirlerini yönetmesine olanak tanır. Uygulama Firebase kullanarak kimlik doğrulama, Firestore ile veri depolama ve Firebase Cloud Messaging (FCM) ile push bildirimleri gönderme özelliklerine sahiptir.

## Özellikler

- OpenWeatherMap API'si kullanılarak gerçek zamanlı hava durumu verisi.
- Favori şehirlerin yönetimi (maksimum 5 şehir).
- Kullanıcının mevcut konumuna göre hava durumu bilgisi.
- Firebase Cloud Messaging (FCM) ile push bildirimleri.
- `Network` framework kullanarak internet bağlantı durumu takibi.

## Gereksinimler

- Xcode 12.0 veya daha yeni bir sürüm
- Swift 5.0 veya daha yeni bir sürüm
- Firebase Proje Yapılandırması (Firestore, Firebase Authentication ve Firebase Cloud Messaging dahil)
- APNs (Apple Push Notification Service) Firebase ile entegre edilmeli

## Kurulum

### 1. Reponun Klonlanması
Bu projeyi yerel makinenize klonlayın:

```bash
git clone https://github.com/mehmetnuriaydin/WeatherApp
```

### 2. Bağımlılıkların Yüklenmesi
Proje, bağımlılık yönetimi için CocoaPods kullanır. Gerekli bağımlılıkları yüklemek için aşağıdaki komutu çalıştırın:

```bash
pod install
```

### 3. Firebase Yapılandırması

- Firebase Konsolu üzerinden yeni bir proje oluşturun (ya da mevcut projeyi kullanın).
- Firebase'de iOS uygulaması ekleyin ve GoogleService-Info.plist dosyasını indirin.
- İndirilen GoogleService-Info.plist dosyasını Xcode projenize ekleyin.
- Firebase Konsolu'nda Firebase Authentication, Firestore ve Cloud Messaging özelliklerini etkinleştirin.
- Firebase'e APNs (Apple Push Notification Service) sertifikanızı yükleyin.

### 4. OpenWeatherMap API Anahtarı
OpenWeatherMap sitesine kaydolup bir API anahtarı oluşturun ve bunu WeatherService sınıfında aşağıdaki gibi ekleyin:

```swift
let apiKey = "api-key"
```

### 5. Push Bildirimlerinin Etkinleştirilmesi

- Xcode'da projenizin "Signing & Capabilities" sekmesine gidin.
- "Push Notifications" ve "Background Modes" (Remote Notifications etkin) özelliklerini ekleyin.
- Uygulamanızın bundle ID'sinin Apple Developer hesabında Push Notifications ile uyumlu olduğundan emin olun.

### 6. APNs Yapılandırması
Push bildirimlerinin düzgün çalışması için APNs'in Firebase projenize düzgün bir şekilde yapılandırıldığından emin olun:

- Apple Developer hesabınıza giderek bir APNs anahtarı oluşturun.
- Firebase Konsolu'nda Cloud Messaging ayarlarına bu APNs anahtarını yükleyin.

### 7. Uygulamanın Çalıştırılması
Push bildirimleri ve konum servisleri sadece gerçek cihazlarda çalışır, bu yüzden uygulamayı gerçek bir cihazda çalıştırdığınızdan emin olun.

Uygulamayı çalıştırmak için Cmd + R tuşuna basabilir veya Xcode'da Run butonuna tıklayabilirsiniz.

## Kullanılan Üçüncü Parti Kütüphaneler

### 1. Firebase
- Firebase Authentication: Kullanıcı kimlik doğrulama ve yönetimi için.
- Firebase Firestore: Kullanıcı verilerinin (örneğin favori şehirler) depolanması için.
- Firebase Cloud Messaging (FCM): Kullanıcılara push bildirimlerinin gönderilmesi için.

Bu kütüphaneler CocoaPods ile yüklenir:

```bash
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Messaging'
```

### 2. Network Framework

Cihazın ağ bağlantı durumunu izlemek için kullanılır.

### 3. OpenWeatherMap API

Gerçek zamanlı hava durumu verilerinin ve tahminlerin alınması için kullanılır.
