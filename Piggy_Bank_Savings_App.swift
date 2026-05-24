//
//  Piggy_Bank_Savings_App.swift
//  Piggy Bank Savings!
//
//  Created by Parchment on 2/27/26.
//

import SwiftUI
import GoogleMobileAds

@main
struct Piggy_Bank_Savings_App: App {
    init() {
        MobileAds.shared.start { _ in
            // AdMob initialized
        }
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
