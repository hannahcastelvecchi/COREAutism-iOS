//
//  WatchConnector.swift
//  COREAutism-iOS
//
//  Created by Hannah Castelvecchi on 3/10/23.
//

// This file contains the code for activating the iOS/watchOS connectivity session (this is currently being used)

import UIKit
import Amplify
import Foundation
import WatchConnectivity

class WatchConnector: UIResponder, UIApplicationDelegate, WCSessionDelegate, ObservableObject {
    
    var session: WCSession
    @Published var receivedFileURL: URL?
    
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
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        if let error = error {
            print("Error transferring file: \(error.localizedDescription)")
        } else {
            print("File transfer completed successfully")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession){
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    // This is the function where we should be recieving the file from watchOS, but for some reason we don't make it this far.
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("Received file")
        if file.fileURL.pathExtension == "m4a" {
            self.receivedFileURL = file.fileURL
            if let url = (self.receivedFileURL){
                let filenameKey = url.lastPathComponent
                print("Uploading file to S3 Database")
                Amplify.Storage.uploadFile(key: filenameKey, local: url)
            }
        }
    }
}
