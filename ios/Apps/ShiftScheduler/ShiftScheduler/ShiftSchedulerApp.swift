//
//  ShiftSchedulerApp.swift
//  ShiftScheduler
//
//  Created by Bennett Smith on 12/6/25.
//

import SwiftUI
import Troop900Bootstrap

@main
struct ShiftSchedulerApp: App {
    /// Use the bootstrap app delegate so FirebaseCore can initialize itself.
    @UIApplicationDelegateAdaptor(BootstrapAppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
