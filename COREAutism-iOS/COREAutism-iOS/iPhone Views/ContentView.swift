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
//import AmplifyPlugins
// Source 1: https://www.youtube.com/watch?v=JQ1370Lw99c

// Source 2: https://www.youtube.com/watch?v=Le1A_PehAFA&t=36s
 
// Source 3: https://www.youtube.com/watch?v=Le1A_PehAFA&t=36s
import SwiftUI
//import AWSAuthCore
import AVFoundation
import AVKit

struct File {
    let name: String
    let url: URL
}

// Create an array of files
/*let files = [
    File(name: "File 1", url: URL(string: "file://path/to/file1.txt")!),
    File(name: "File 2", url: URL(string: "file://path/to/file2.txt")!)
]*/

struct ContentView: View {
    @State private var watchActivated = false
    @State private var watchMessage = ""
    @State var files: [URL] = []
    
    @ObservedObject var watchConnection = WatchConnector()
    
    func activateWatch() {
        if let session = Optional(self.watchConnection.session) {
            if session.isReachable {
                print("WatchOS - Watch is available.")
                self.watchActivated = true
                
                self.getFilesFromWatch()
                
            } else {
                print("WatchOS - Watch is not reachable.")
            }
        } else {
            print("WatchOS - Session is not available.")
        }

    }
    /*
    func sendMessageToWatch() {
        if self.watchConnection.session.isReachable {
            print("WatchOS - Watch is available")
            self.watchActivated = true
            self.watchConnection.session.sendMessage(["message" : String(self.watchMessage)], replyHandler: nil) { (error) in
                print("WatchOS ERROR SENDING MESSAGE - " + error.localizedDescription)
            }
        }
        else {
            print("WatchOS - Watch is unavailable. Make your Apple Watch is unlocked.")
            self.watchActivated = false
        }
    }
    */
    
    func getFilesFromWatch() {
        print("getting files from watch....")
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: documentsDirectory.path)
            
            for fileName in fileNames {
                print(fileName)
            }
        } catch {
            print("Error getting file names: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let fileName = message["fileName"] as? String, let fileURL = message["fileURL"] as? URL {
            Amplify.Storage.uploadFile(key: fileName, local: fileURL)
            // Add the file to the list of files
            DispatchQueue.main.async {
                self.files.append(fileURL)
            }
            print("Received file: \(fileName)")
        }
    }
      
    var body: some View {
        NavigationView {
                VStack {
                    List(files, id: \.self) { file in
                    NavigationLink(destination: Text(file.lastPathComponent)) {
                    Text(file.lastPathComponent)
                    }
                }
                .navigationTitle("Files")
            }
        }
        .onAppear {
            self.activateWatch()
        }
    }
}
/*
    var body: some View {
        VStack {
            List(files, id: \.url) { file in
                NavigationLink(destination: Text(file.name)){
                    Text(file.name)
                }
            }.navigationTitle("Files")
            // Activate
            Button(action: {
                self.activateWatch()
            }, label: {
                Text("Activate Watch App")
            })
            
            if (self.watchActivated){
                Text("Watch activated. Check your watch app")
            }
            else {
                Text("Watch app inactivate. Tap Activate button to refresh")
            }
            
            // Communicate
            /*TextField("Enter a message to send to watch: ", text: self.$watchMessage)
            Button(action: {
                self.sendMessageToWatch()
            }, label: {
                Text("Send message")
            }) */
        }
        .padding()
        .onAppear() {
            self.activateWatch()
        }
    }
} */

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
 }

