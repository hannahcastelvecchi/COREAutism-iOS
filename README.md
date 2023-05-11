# COREAutism-iOS
An iOS/watchOS project that records audio files on an apple watch, transfers the files to an iPhone, and uploads the files to an Amazon S3 database. 

# Description
The CORE Autism iOS/watchOS project is designed to monitor the voice activity of patients with autism over a set period of time.
The project contains the configurations between the watch and the phone that allows them to communicate with each other.
When both the watch and phone programs are executed, they are connected via a Watch Connectivity session. The apple watch displays a record button that records audio from the microphone of the watch when pressed. The audio file is displayed on the watch, and then is displayed on the phone under "Files" once it has been receieved. Then, the file is transfered to the S3 database where it may be downloaded and played from there.

# Getting Started
1. Make sure you have the Xcode version 14.0 or above installed on your computer.
2. Make sure the iPhone and Apple Watch are paired, up to date, and in developer mode.
3. In order to configure a new Amazon S3 database, you must initialize a new Amplify project and create an environment on Terminal. Then, you must add S3 storage to the environment, creating a new S3 bucket.
The steps for configuration can be found in this video tutorial: https://www.youtube.com/watch?v=4k2zNLIkHYs
4. Once the Amplify and S3 database are configured, open the .xcodeproj file in Xcode.
5. Using either the simulators for Apple Watch Series 8 and iPhone 14 pro, or the physical devices, run "CORE Autism-iOS WatchKit App" and then "CORE Autism-iOS". This runs the programs for the watch and phone respectfully.
6. You should see the displays of both the watch and the phone on their respective screens. From there, the audio recording and file transfers described above may be initiated.

# Usage
Once both the Apple Watch and iPhone apps are running, follow these steps to use them:

- Toggle the red, circular record button on the watch. When the red button has a white outline, the watch is actively recording audio. The recording will continue for 10 seconds and then the button will toggle automatically. You should see the recording file appear on the screen. NOTE: if the record button is toggled before the 10 seconds is finished, recording will stop and the file will be discarded.
- The file that has just been recorded will appear under "Files" on the iPhone in the format "recording#.m4a"
- Navigate to the configured S3 bucket. The file, "recording#.m4a" will appear as the most recently modified file in the bucket. From there, you may download and play the file.

# Architecture 
- COREAutism-iOS project is implemented using the Model-View-Control (MVC) architecture pattern for both the Apple Watch and iPhone views.
- Model has any necessary data or business logic needed to generate both displays.
- View is responsible for displaying the user interfaces of the watch and phone.
- Controller handles any user input or interactions and updtes the Model and View as needed.
- Project is configured to an Amazon S3 database where the audio files created by the application are stored.

# Dependencies 
List of Package Dependencies:
- Amplify
- AmplifyUtilsNotifications
- AppSyncRealTimeClient
- aws-crt-swift
- aws-sdk-swift
- smithy-swift
- SQLite.swift
- Starscream
- Swift-collections
- swift-log
- XMLCoder

# Application Demo

https://github.com/hannahcastelvecchi/COREAutism-iOS/assets/56701614/9da2fcaa-a575-44d8-a694-1b48de84e84e


