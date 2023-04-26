//
//  ContentView.swift
//  COREAutism-iOS WatchKit Extension
//
//  Created by Hannah Castelvecchi on 3/10/23.
//

import SwiftUI
import Foundation
import AVFoundation
import AVKit
import WatchConnectivity
import CoreFoundation
//import Amplify

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
    @State var Timer1: Timer?
    @State var Timer2: Timer?
    
    // This is where we connect iOS/watchOS
    @ObservedObject var watchConnection = WatchConnector()
    
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
                            print("Recording stopped due to button toggle.")
                            print("Did not finish the recording. File will be discarded")
                            return
                        }
                        
                        let fileName = recordAudio(audioList: audios)
                        
                        // wait for recording
                        Timer2 = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
                            if fileName == nil {
                                print("File was nil.")
                            }
                            print("Recording stopped automatically after 10 seconds")
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
                
                // request permission for microphone
                
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
        print("Recording...")
        
        let tempDirectory = NSTemporaryDirectory()
        
        let fileName = URL(fileURLWithPath: tempDirectory).appendingPathComponent("recording\(audioList.count + 1).m4a")
        
        let settings = [ AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 44100, AVNumberOfChannelsKey: 2, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        
        do {
            let recorder = try AVAudioRecorder(url: fileName, settings: settings)
            recorder.record()
            
            Timer1 = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
                recorder.stop()
            
                                if isPlayable(audioURL: fileName){
                    print("The file is playable. This is where it would upload to database.")
                    
                    // This is where the file should be transferred, but the "transferFile" function is not working
                    
                    print("HERE IS WHERE THE FILE WOULD BE TRANSFERRED")
                    if WCSession.isSupported() {
                        if self.watchConnection.session.isReachable {
                            /*
                            print("Signaling file transfer.")
                            // sending a message to iOS to signal file transfer
                            let message = ["message": "new file created"]
                            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                                print("Error sending message: \(error.localizedDescription)")
                            }) */
                            do {
                                let fileData = try Data(contentsOf: fileName)
                                let message = ["fileData": fileData]
                                WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { (error) in
                                    print("Error sending file data: \(error.localizedDescription)")
                                })
                            } catch {
                                print("Error getting file data: \(error.localizedDescription)")
                            }
                        }
                    }
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
