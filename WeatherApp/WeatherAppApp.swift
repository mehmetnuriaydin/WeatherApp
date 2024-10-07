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
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoginView()
                        }
        }
    }
}
