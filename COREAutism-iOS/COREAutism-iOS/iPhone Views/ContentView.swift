//
//  ContentView.swift
//  COREAutism-iOS
//
//  Created by Hannah Castelvecchi on 3/10/23.
//

// The following code (the uncommented section) is identical to the recorder application on the watchOS side. This is for testing purposes since we aren't yet able to transfer files from the watch to the iphone, and only iOS supports Amplify (which is uploads the files to the database)

import SwiftUI
import Foundation
import AVFoundation
import AVKit
import WatchConnectivity
import Amplify

// Source 1: https://www.youtube.com/watch?v=JQ1370Lw99c

// Source 2: https://www.youtube.com/watch?v=Le1A_PehAFA&t=36s

// Source 3: https://www.youtube.com/watch?v=4k2zNLIkHYs

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView().preferredColorScheme(.dark)
    }
}

struct RecordButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(width: 55, height: 55)
            .clipShape(Circle())
    }
}

struct ContentView: View {
    @State var record = false
    @State var AVsession: AVAudioSession!
    @State var recorder: AVAudioRecorder!
    @State var alert = false
    @State var audios : [URL] = []
    @State var message = ""
    @State private var iPhoneActivated = false
    @State private var watchMessage = ""
    @State var Timer1: Timer?
    @State var Timer2: Timer?
    
    // this is what is used for watchOS/iOS connectivity session
    //@ObservedObject var watchConnection = WatchConnector()
    
    var body: some View {
        
        NavigationView{
            VStack{
                
                List(self.audios, id: \.self) { i in
                    
                    Text(i.relativeString)
                }
                
                Button(action: {
                    // recording audio
                    do{
                        if self.record{
                            // already recording, toggle stop
                            Timer1?.invalidate()
                            Timer2?.invalidate()
                            Timer1 = nil
                            Timer2 = nil
                            self.record.toggle()
                            // recording was stopped before minimum length
                            print("Did not finish the recording. File will be discarded")
                            return
                        }
                        
                        let fileName = recordAudio(audioList: audios)
                        
                        // wait for recording
                        Timer2 = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
                            if fileName == nil {
                                print("File was nil.")
                            }
                            self.record.toggle()
                            self.getAudios()
                        }
                    }
                    
                }){
                    ZStack{
                        Circle().fill(Color.red)
                            .frame(width: 40, height: 40)
                        
                        if self.record{
                            
                            Circle().stroke(Color.white, lineWidth: 6).frame(width: 55, height: 55)
                        }
                    }
                }
                //.padding(.vertical, 25)
                .buttonStyle(RecordButtonStyle())
            }
            .navigationBarTitle("Record Audio")
        }
        .alert(isPresented: self.$alert, content: {
            
            Alert(title: Text("Error"), message: Text("Enable Access"))
        })
        .onAppear(){
            do{
                self.AVsession = AVAudioSession.sharedInstance()
                try self.AVsession.setCategory(.playAndRecord)
                self.getAudios()
                
                // crashing for some reason:
                
                // request permission for microphone
                /*
                self.AVsession.requestRecordPermission{(status) in
                
                    if !status {
                        
                        // error
                        self.alert.toggle()
                    }
                    else {
                        // permission granted
                        self.getAudios()
                    }
                }
                */
            }
            catch{
                print(error.localizedDescription)
            }
        }
    }
    func isPlayable(audioURL: URL) -> Bool {
        let asset = AVAsset(url: audioURL)
        let playable = asset.isPlayable
        return playable
    }
    
    func recordAudio(audioList: [URL]) -> URL? {
        
        record.toggle()
        
        let myString = self.record ? "Recording" : "Couldn't record"
        print(myString)
        
        let tempDirectory = NSTemporaryDirectory()
        
        let fileName = URL(fileURLWithPath: tempDirectory).appendingPathComponent("recording\(audioList.count + 1).m4a")
        
        let settings = [ AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 44100, AVNumberOfChannelsKey: 2, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        
        do {
            let recorder = try AVAudioRecorder(url: fileName, settings: settings)
            recorder.record()
            
            Timer1 = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
                recorder.stop()
            
                let filenameKey : String = "recording\(audios.count + 1).m4a"

                if isPlayable(audioURL: fileName){
                    print("The file is playable. Upload file.")
                    Amplify.Storage.uploadFile(key: filenameKey, local: fileName)
                }
                else
                {
                    print("The file is not playable.")
                }
            }
            return fileName
            
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getAudios(){
        
        do {
            let url = FileManager.default.temporaryDirectory
            
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            
            // Remove old data
            self.audios.removeAll()
            
            for i in result {
                self.audios.append(i)
            }
        }
        catch{
            print(error.localizedDescription)
        }
    }
}

// This portion of code is what will be used as the base for when watch connectivity/transfering files is working properly

/*
import SwiftUI
import Foundation
import AVFoundation
import AVKit
import WatchConnectivity
//import Amplify
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
let files = [
    File(name: "File 1", url: URL(string: "file://path/to/file1.txt")!),
    File(name: "File 2", url: URL(string: "file://path/to/file2.txt")!)
]

struct ContentView: View {
    @State private var watchActivated = false
    @State private var watchMessage = ""
    
    @ObservedObject var watchConnection = WatchConnector()
    
    func activateWatch() {
        
        if self.watchConnection.session.isReachable {
            print("WatchOS - Watch is available.")
            self.watchActivated = true
            
            //self.getFilesFromWatch()
        }
        else {
            print("WatchOS - Watch is unavailable.")
            self.watchActivated = false
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
    } */

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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
 }  */
