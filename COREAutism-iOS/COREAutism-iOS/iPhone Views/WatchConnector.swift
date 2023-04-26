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
    
    // If message is received, file is transfered to database.
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        /*
        self.receivedFileURL = getMostRecentFileInTempDirectory()
        print("File transferred.")
        self.receivedFileNameKey = self.receivedFileURL?.lastPathComponent
        print("Uploading file to S3 database.")
        Amplify.Storage.uploadFile(key: self.receivedFileNameKey!, local: self.receivedFileURL!)
        print("Appending file to iPhone list view.")
        self.files.append(self.receivedFileURL!)
         */
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
    
    func getMostRecentFileInTempDirectory() -> URL? {
        let fileManager = FileManager.default
        let tempDirectory = NSTemporaryDirectory()
        
        guard let directoryContents = try? fileManager.contentsOfDirectory(atPath: tempDirectory) else {
            return nil
        }
        
        let sortedContents = directoryContents.sorted {
            let file1URL = URL(fileURLWithPath: tempDirectory).appendingPathComponent($0)
            let file2URL = URL(fileURLWithPath: tempDirectory).appendingPathComponent($1)
            guard let file1CreationDate = try? fileManager.attributesOfItem(atPath: file1URL.path)[.creationDate] as? Date,
                  let file2CreationDate = try? fileManager.attributesOfItem(atPath: file2URL.path)[.creationDate] as? Date
            else {
                return false
            }
            return file1CreationDate > file2CreationDate
        }
        
        guard let mostRecentFile = sortedContents.first else {
            return nil
        }
        
        return URL(fileURLWithPath: tempDirectory).appendingPathComponent(mostRecentFile)
    }
}
