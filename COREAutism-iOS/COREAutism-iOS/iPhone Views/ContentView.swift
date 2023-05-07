//
//  ContentView.swift
//  COREAutism-iOS
//
//  Created by Hannah Castelvecchi on 3/10/23.
//
// This portion of code is what will be used as the base for when watch connectivity/transfering files is working properly
import SwiftUI
import Foundation
import AVFoundation
import AVKit
import WatchConnectivity
import Amplify
// Source 1: https://www.youtube.com/watch?v=JQ1370Lw99c

// Source 2: https://www.youtube.com/watch?v=Le1A_PehAFA&t=36s

// Source 3: https://www.youtube.com/watch?v=4k2zNLIkHYs


import SwiftUI
import AVFoundation
import AVKit

struct ContentView: View {
    @State private var watchActivated = false
    @State var receivedFileURL: URL?
    
    @ObservedObject var watchConnection = WatchConnector()
    
    func activateWatch() {
        
        if WCSession.isSupported() {
            if self.watchConnection.session.isReachable {
                    print("WatchOS - Watch is available.")
                    self.watchActivated = true
                } else {
                    print("WatchOS - Session is not available.")
                }
            } else {
                print("WatchOS - Watch session is not supported.")
            }
    }
     
    var body: some View {
        NavigationView {
                VStack {
                    if self.watchConnection.files.isEmpty{
                        Text("")
                        .navigationTitle("Files")
                    }
                    else {
                        
                        List(self.watchConnection.files, id: \.self) { file in
                        NavigationLink(destination: Text(file.lastPathComponent)) {
                                Text(file.lastPathComponent)
                            // Add functionality for playing the file
                            }
                        }
                        .navigationTitle("Files")
                    }
            }
        }
        .onAppear {
            self.activateWatch()
            self.watchConnection.getFiles()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
 }

