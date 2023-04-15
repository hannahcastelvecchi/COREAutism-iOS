//
//  COREAutism_iOSApp.swift
//  COREAutism-iOS
//
//  Created by Hannah Castelvecchi on 3/10/23.
//

// This file contains the AWS S3/Amplify configuration

import AWSCognitoAuthPlugin
import AWSS3StoragePlugin
import Amplify
import SwiftUI

@main
struct COREAutism_iOSApp: App {
    
    init() {
        configureAmplify()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            
            try Amplify.configure()
            print("Successfully configured Amplify")
            
        } catch {
            print("Could not configureAmplify", error)
        }
    }
}
