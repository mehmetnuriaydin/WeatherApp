import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Hoş Geldin!")
                .font(.largeTitle)
                .padding()

            Text("Giriş başarılı oldu.")
        }
        .navigationBarTitle("Ana Sayfa", displayMode: .inline)
    }
}
