//
//  WatchConnector.swift
//  COREAutism-iOS WatchKit Extension
//
//  Created by Hannah Castelvecchi on 3/10/23.
//

import UIKit
import WatchConnectivity
import Foundation
import AVFoundation
import AVKit

// This file contains the code for activating the iOS/watchOS connectivity session (this is currently being used)

class WatchConnector: NSObject, WCSessionDelegate,  ObservableObject {
    var session: WCSession

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
            print("Watch session activated")
        }
    }
}
