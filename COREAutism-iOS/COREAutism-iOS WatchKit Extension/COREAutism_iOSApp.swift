//
//  COREAutism_iOSApp.swift
//  COREAutism-iOS WatchKit Extension
//
//  Created by Hannah Castelvecchi on 3/10/23.
//

import SwiftUI

@main
struct COREAutism_iOSApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
