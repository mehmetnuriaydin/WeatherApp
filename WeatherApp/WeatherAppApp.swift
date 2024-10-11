//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Nuri ABT on 6.10.2024.
//

import SwiftUI

@main
struct WeatherAppApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // NetworkStatusManager'ı @StateObject olarak tanımlıyoruz
    @StateObject private var networkStatusManager = NetworkStatusManager()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoginView()
                    .environmentObject(networkStatusManager) // Network durumu tüm view'lere aktarılıyor
            }
        }
    }
}
