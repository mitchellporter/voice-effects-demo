//
//  CameraViewController.swift
//  VoiceEffectsDemo
//
//  Created by Mitchell Porter on 3/12/16.
//  Copyright © 2016 Mentor Ventures, Inc. All rights reserved.
//

import UIKit
import SCRecorder

class CameraViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    
    
    // MARK: SCRecorder
    let recorder = SCRecorder()
    var recordSession: SCRecordSession?
    let recordingTimeLimit: Int64 = 8 // 20 second video record time limit
    var player: SCPlayer?
    var playerLayer: AVPlayerLayer?
    
    // MARK: AudioEngine
    let audioEngine  = AVAudioEngine()
    var audioPlayer: AVAudioPlayer!
    var audioFile: AVAudioFile!
    
    var recordedAudioURL: NSURL!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAudioEngine()
        setupRecorder()
        recorder.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        recorder.previewViewFrameChanged()
    }
    
    func setupAudioEngine() {
        
//        audioEngine.prepare()

        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as String
        
        let currentDateTime = NSDate();
        let formatter =  NSDateFormatter();
        formatter.dateFormat =  "ddMMyyyy-HHmmss";
        
        // NOTE: You have to use .aac, for some reason .m4a always saves an invalid file
        // The following link is also a perfect example of tapping microphone input
        // See here: http://stackoverflow.com/questions/24401609/avfoundation-malformed-m4a-file-format-using-avaudioengine-and-avaudiofile
        let recordingName = formatter.stringFromDate(currentDateTime)+".aac"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print(filePath)
        recordedAudioURL = filePath
        

        var audioFileSettings = Dictionary<String, AnyObject>()
        audioFileSettings[AVFormatIDKey]                 = NSNumber(unsignedInt: kAudioFormatMPEG4AAC)
        audioFileSettings[AVNumberOfChannelsKey]         = 1
        audioFileSettings[AVSampleRateKey]               = 44100.0
        audioFileSettings[AVEncoderBitRatePerChannelKey] = 16
        audioFileSettings[AVEncoderAudioQualityKey]      = AVAudioQuality.Medium.rawValue
        
        let inputNode = audioEngine.inputNode
        
        do {
            try self.audioFile = AVAudioFile(forWriting: recordedAudioURL, settings: audioFileSettings)
        } catch _ {
            print("Failed to create audio file")
        }
        
        // Write the output of the input node to disk
        inputNode!.installTapOnBus(0, bufferSize: 4096,
            format: inputNode!.outputFormatForBus(0),
            block: { (audioPCMBuffer : AVAudioPCMBuffer!, audioTime : AVAudioTime!) in
                
                do {
                    print("Writing data to audio file...")
                    try self.audioFile.writeFromBuffer(audioPCMBuffer)
                } catch _ {
                    print("Failed to create audio file")
                }
        })
        
        startRecordingAudio()
    }
    
    func startRecordingAudio() {
        do {
            try audioEngine.start()
        } catch _ {
            print("AUDIO ENGINE CATCH")
        }
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "stopRecordingAudio", userInfo: nil, repeats: false)
    }
    
    func stopRecordingAudio() {
        audioEngine.inputNode?.removeTapOnBus(0)
        audioEngine.stop()
        
        // Playback the audio we've captured
        playRecordedAudio()
    }
    
    func playRecordedAudio() {
        // Setup audio engine + player
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: recordedAudioURL.filePathURL!)
        }  catch let error as NSError {
                print("Failed to create audio player")
                print(error.localizedDescription)
            
        }
        audioPlayer.numberOfLoops = 100 // Negative value = infinite loops
        audioPlayer.volume = 50.0
        audioPlayer.enableRate = true
        
//        audioFile = try? AVAudioFile(forReading: recordedAudioURL)
        
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        let pitchPlayer = AVAudioPlayerNode()
        pitchPlayer.volume = 1.0
        audioEngine.attachNode(pitchPlayer)
        
        let timePitch = AVAudioUnitTimePitch()
        timePitch.pitch = 1000 // In cents. The default value is 1.0. The range of values is -2400 to 2400
        audioEngine.attachNode(timePitch) //The default value is 1.0. The range of supported values is 1/32 to 32.0.
        
        audioEngine.connect(pitchPlayer, to: timePitch, format: nil)
        audioEngine.connect(timePitch, to: audioEngine.mainMixerNode, format: nil)
        
        pitchPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        do {
            try audioEngine.start()
        } catch _ {
        }
        pitchPlayer.play()
    }

    func setupRecorder() {
        print("Setup resoluton: \(SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices())")
        recorder.captureSessionPreset = SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices()
        print(recorder.captureSessionPreset)
        recorder.maxRecordDuration = CMTimeMake(recordingTimeLimit, 1)
        recorder.delegate = self
        recorder.device = .Front
        recorder.mirrorOnFrontCamera = true
        recorder.previewView = self.previewView
        recorder.initializeSessionLazily = false
        
        do {
            try recorder.prepare()
            print("About to try preparing the recorder")
        } catch {
            print("An error occurred when trying to prepare the recorder")
        }
    }

    @IBAction func recordButtonPressed(sender: AnyObject) {
        if recorder.session == nil {
            let session = SCRecordSession()
            session.fileType = AVFileTypeQuickTimeMovie
            recorder.session = session
        }
        // Start recording
        startRecordingAudio()
        recorder.record()
    }
    
    @IBAction func playAudioButtonPressed() {
        
    }
}

extension CameraViewController: SCAssetExportSessionDelegate {
    
    func assetExportSessionDidProgress(assetExportSession: SCAssetExportSession) {
        print("Export session progress: \(assetExportSession.progress)")
    }
}

extension CameraViewController: SCRecorderDelegate {
    
    func recorder(recorder: SCRecorder, didSkipVideoSampleBufferInSession session: SCRecordSession) {
        print("Skipped video buffer")
    }
    
    func recorder(recorder: SCRecorder, didAppendVideoSampleBufferInSession session: SCRecordSession) {
        
        // Start updating progress bar
        let recordedSeconds = CMTimeGetSeconds((recorder.session?.duration)!)
        let percentage = CGFloat(recordedSeconds / 20.0)
        let progress = CGFloat(percentage * UIScreen.mainScreen().bounds.size.width)
        
        print("Progress: \(progress)")
    }
    
    func recorder(recorder: SCRecorder, didCompleteSegment segment: SCRecordSessionSegment?, inSession session: SCRecordSession, error: NSError?) {
        print("completed segement")
    }
    
    func recorder(recorder: SCRecorder, didBeginSegmentInSession session: SCRecordSession, error: NSError?) {
        print("begin new segment")
    }
    
    func recorder(recorder: SCRecorder, didCompleteSession session: SCRecordSession) {
        print("completed session")
    }
    
    func recorder(recorder: SCRecorder, didReconfigureAudioInput audioInputError: NSError?) {
        print("Reconfigured audio input: \(audioInputError)")
    }
    
    func recorder(recorder: SCRecorder, didReconfigureVideoInput videoInputError: NSError?) {
        print("Reconfigured video input: \(videoInputError)")
    }
}
