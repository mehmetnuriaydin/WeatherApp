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
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: signIn) {
                    Text("Giriş Yap")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                Text(loginMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            .padding()
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
