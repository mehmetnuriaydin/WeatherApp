import SwiftUI
import FirebaseAuth

struct LoginView: View {
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

                    // Hata veya başarı mesajı
                    if !loginMessage.isEmpty {
                        Text(loginMessage)
                            .foregroundColor(.yellow)
                            .fontWeight(.semibold)
                            .padding(.top, 10)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .center) // Ortalamak için
            }
        }
    }

    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                loginMessage = "Giriş hatası: \(error.localizedDescription)"
            } else {
                loginMessage = "Giriş başarılı!"
                isLoggedIn = true // Başarılı girişte kullanıcıyı anasayfaya yönlendirmek için
            }
        }
    }
}
