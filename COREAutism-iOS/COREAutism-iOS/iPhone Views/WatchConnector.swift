//
//  WatchConnector.swift
//  COREAutism-iOS
//
//  Created by Hannah Castelvecchi on 3/10/23.
//

// This file contains the code for activating the iOS/watchOS connectivity session

import UIKit
import Amplify
import Foundation
import AVFoundation
import AVKit
import WatchConnectivity

class WatchConnector: UIResponder, UIApplicationDelegate, WCSessionDelegate, ObservableObject {
    
    var session: WCSession
    var receivedFileURL: URL?
    var receivedFileNameKey: String?
    @Published var files: [URL] = []
    
    init(session: WCSession = .default){
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Error activating session: \(error.localizedDescription)")
        } else {
            print("iPhone session activated")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession){
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    // If message is received, file is transfered to database.
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let fileData = message["fileData"] as? Data {
            let tempDirectory = NSTemporaryDirectory()
            self.receivedFileURL = URL(fileURLWithPath: tempDirectory).appendingPathComponent("recording\(self.files.count + 1).m4a")
            self.receivedFileNameKey = receivedFileURL?.lastPathComponent
            
            do {
                try fileData.write(to: self.receivedFileURL!)
                print("Appending file to iPhone list view.")
                self.files.append(self.receivedFileURL!)
                print("Uploading file to S3 database.")
                Amplify.Storage.uploadFile(key: self.receivedFileNameKey!, local: self.receivedFileURL!)
            } catch {
                    print("Error saving file data: \(error.localizedDescription)")
            }
        }
    }
}
