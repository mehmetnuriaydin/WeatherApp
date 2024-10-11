import SwiftUI
import FirebaseCore
import FirebaseMessaging
import Network
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    var networkStatusManager = NetworkStatusManager() // Ağ durumu izleyici

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure() // Firebase yapılandırması
        
        // Ağ durumu kontrolü başlat
        networkStatusManager.startMonitoring()
        
        // Bildirim izinlerini talep et
        requestNotificationAuthorization(application)
        
        // FCM Messaging Delegate ayarla
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // Bildirim izinlerini talep etme fonksiyonu
    private func requestNotificationAuthorization(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Bildirim izni alma hatası: \(error.localizedDescription)")
            }
            
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("Bildirim izni verilmedi.")
            }
        }
    }
    
    // Remote Notification alındığında tetiklenir (APNs token)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs Token alındı: \(deviceToken)")
        
        // APNs token'ını FCM'e kaydet
        Messaging.messaging().apnsToken = deviceToken
        
        // APNs token'ı string formatında
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("APNs Token: \(token)")
    }

    // FCM token yenilendiğinde tetiklenir
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("FCM token yenilendi: \(fcmToken)")
        
        // FCM token'ı backend'e kaydetme işlemlerini buraya ekleyebilirsiniz
        sendFCMTokenToServer(fcmToken)
    }
    
    // FCM token'ını backend'e gönderme fonksiyonu
    func sendFCMTokenToServer(_ token: String) {
        // Backend'e token'ı kaydetme işlemleri buraya eklenebilir
        print("FCM token backend'e gönderiliyor: \(token)")
    }
    
    // Uygulama ön plandayken bildirim alındığında tetiklenir
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Bildirimleri nasıl göstereceğinizi seçin (örneğin, banner, ses, rozet)
        completionHandler([.banner, .sound, .badge])
    }
    
    // Bildirime tıklandığında tetiklenir
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Bildirime tıklandığında yapılacak işlemleri buraya ekleyin
        completionHandler()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Uygulama sonlanmadan önce ağ izlemeyi durdur
        //networkStatusManager.stopMonitoring()
    }
}
