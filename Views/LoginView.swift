import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var networkStatusManager: NetworkStatusManager // İnternet durumu için

    @State private var email = ""
    @State private var password = ""
    @State private var loginMessage = ""
    @State private var isLoggedIn = false // Giriş durumunu kontrol eden değişken

    var body: some View {
        if isLoggedIn {
            HomeView() // Giriş yapıldıysa HomeView'e yönlendirme
        } else {
            ZStack {
                // Arka plan için mavi tonlarıyla gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.8)]),
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    // Başlık
                    Text("WeatherApp'e Hoşgeldiniz")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    // E-posta alanı
                    TextField("E-posta Adresi", text: $email)
                        .autocapitalization(.none)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)

                    // Şifre alanı
                    SecureField("Şifre", text: $password)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)

                    // Giriş yap butonu
                    Button(action: signIn) {
                        Text("Giriş Yap")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]),
                                                       startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .padding(.horizontal, 40)
                    }
                    .disabled(!networkStatusManager.isConnected) // Ağ yoksa buton devre dışı

                    // Hata veya başarı mesajı
                    if !loginMessage.isEmpty {
                        Text(loginMessage)
                            .foregroundColor(loginMessage.contains("başarılı") ? .green : .yellow) // Başarı mesajı yeşil, hata mesajı sarı
                            .fontWeight(.semibold)
                            .padding(.top, 10)
                            .multilineTextAlignment(.center)
                    }

                    // İnternet bağlantısı kontrolü
                    if !networkStatusManager.isConnected {
                        Text("İnternet bağlantısı yok!")
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                    }

                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .center) // Ortalamak için
            }
        }
    }

    // Giriş yapma işlevi
    func signIn() {
        // İnternet bağlantısı yoksa giriş işlemi yapılmasın
        guard networkStatusManager.isConnected else {
            loginMessage = "İnternet bağlantısı yok. Lütfen internet bağlantınızı kontrol edin."
            return
        }

        guard !email.isEmpty, !password.isEmpty else {
            loginMessage = "E-posta ve şifre alanları boş bırakılamaz."
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                loginMessage = parseFirebaseError(error: error)
            } else {
                loginMessage = "Giriş başarılı!"
                isLoggedIn = true // Başarılı girişte kullanıcıyı anasayfaya yönlendirmek için
            }
        }
    }

    // Firebase hata mesajlarını kullanıcılara daha anlaşılır hale getiren fonksiyon
    func parseFirebaseError(error: NSError) -> String {
        let errorCode = AuthErrorCode(rawValue: error.code)

        switch errorCode {
        case .invalidEmail:
            return "Geçersiz e-posta formatı. Lütfen geçerli bir e-posta adresi girin."
        case .wrongPassword:
            return "Hatalı şifre. Lütfen şifrenizi kontrol edin."
        case .userNotFound:
            return "Bu e-posta adresine ait bir kullanıcı bulunamadı."
        case .networkError:
            return "Ağ bağlantısı sağlanamadı. Lütfen internet bağlantınızı kontrol edin."
        case .tooManyRequests:
            return "Çok fazla giriş denemesi yaptınız. Lütfen daha sonra tekrar deneyin."
        default:
            return "Bilinmeyen bir hata oluştu. \(error.localizedDescription)"
        }
    }
}
