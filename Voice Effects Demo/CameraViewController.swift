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
        
        // Install a tap on bus 0 aka the microphone
        let inputNode = audioEngine.inputNode
        let bus = 0
        inputNode!.installTapOnBus(bus, bufferSize: 2048, format:inputNode!.inputFormatForBus(bus)) {
            (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
            print(time)
        }
        
        audioEngine.prepare()
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "startRecordingAudio", userInfo: nil, repeats: false)
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
        audioEngine.stop()
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
