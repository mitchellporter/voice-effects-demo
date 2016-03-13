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
    let recordingTimeLimit: Int64 = 10 // 20 second video record time limit
    var player: SCPlayer?
    var playerLayer: AVPlayerLayer?
    
    // MARK: AudioEngine
    let audioEngine  = AVAudioEngine()
    var audioPlayer: AVAudioPlayer!
    var audioFile: AVAudioFile!
    
    // Nodes
    var pitchPlayer: AVAudioPlayerNode!
    var timePitch: AVAudioUnitTimePitch!
    
    // Url of recording
    var recordedAudioURL: NSURL!
    var processedAudioURL: NSURL!
    var processedAudioFile: AVAudioFile!
    var audioToolsTestURL: NSURL!
    
    var reverb = AVAudioUnitReverb()
    
    var processingTracker = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupAudioEngine()
        setupRecorder()
        recorder.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        recorder.previewViewFrameChanged()
    }
    
    // NOTE: Here is the stackoverflow link that provided this function: http://stackoverflow.com/a/35860199/3344977
    func initializeAudioEngine() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            
            let ioBufferDuration = 128.0 / 44100.0
            
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(ioBufferDuration)
            
        } catch {
            assertionFailure("AVAudioSession setup error: \(error)")
        }
        
        
        
        let input = audioEngine.inputNode! //get the input node
        let output = audioEngine.outputNode //get the output node
        let format = input.inputFormatForBus(0) //format
        
        
        //applying some reverb effects
        reverb.loadFactoryPreset(.MediumChamber)
        reverb.wetDryMix = 50
        audioEngine.attachNode(reverb)
        
        //connecting the nodes
        audioEngine.connect(input, to: reverb, format: format)
        audioEngine.connect(reverb, to:audioEngine.mainMixerNode, format: format)
        
        // Setup engine and node instances
        assert(audioEngine.inputNode != nil)
        
        // Start engine
        do {
            try audioEngine.start()
        } catch {
            assertionFailure("AVAudioEngine start error: \(error)")
        }
        //At this point, your engine is setup and you should here your sound input from microphone in your speaker/earphones.
        //Now time to install tap on input bus to get buffered data:
        
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
        
//        var audioFileSettings = Dictionary<String, AnyObject>()
//        audioFileSettings[AVFormatIDKey]                 = NSNumber(unsignedInt: kAudioFormatMPEG4AAC)
//        audioFileSettings[AVNumberOfChannelsKey]         = 1
//        audioFileSettings[AVSampleRateKey]               = 44100.0
//        audioFileSettings[AVEncoderBitRatePerChannelKey] = 16
//        audioFileSettings[AVEncoderAudioQualityKey]      = AVAudioQuality.Medium.rawValue
        
        var audioFileSettings = Dictionary<String, AnyObject>()
        audioFileSettings[AVFormatIDKey]                 = NSNumber(unsignedInt: kAudioFormatLinearPCM)
        audioFileSettings[AVNumberOfChannelsKey]         = 2
        audioFileSettings[AVSampleRateKey]               = 44100.0
        audioFileSettings[AVLinearPCMBitDepthKey] = 16
        audioFileSettings[AVLinearPCMIsBigEndianKey]      = 0
        audioFileSettings[AVLinearPCMIsFloatKey]      = 0

        
        
        
        do {
            try self.audioFile = AVAudioFile(forWriting: recordedAudioURL, settings: audioFileSettings)
        } catch let error as NSError {
            print("Failed to create audio FILE")
            print(error.localizedDescription)
            
        }
        
        
        audioEngine.inputNode?.installTapOnBus(0, bufferSize: 2048, format: format, block: { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
            
            //here you can examine the input data
            print("sfdljk")
            do {
                print("Writing data to audio file...")
                try self.audioFile.writeFromBuffer(buffer)
            } catch let error as NSError {
                print("Failed to create audio file")
                print(error.localizedDescription)
                
            }
        })
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
        let recordingName = formatter.stringFromDate(currentDateTime)+".caf"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print(filePath)
        recordedAudioURL = filePath

        
//        var audioFileSettings = Dictionary<String, AnyObject>()
//        audioFileSettings[AVFormatIDKey]                 = NSNumber(unsignedInt: kAudioFormatMPEG4AAC)
//        audioFileSettings[AVNumberOfChannelsKey]         = 1
//        audioFileSettings[AVSampleRateKey]               = 44100.0
//        audioFileSettings[AVEncoderBitRatePerChannelKey] = 16
//        audioFileSettings[AVEncoderAudioQualityKey]      = AVAudioQuality.Medium.rawValue
        
        var audioFileSettings = Dictionary<String, AnyObject>()
        audioFileSettings[AVFormatIDKey]                 = NSNumber(unsignedInt: kAudioFormatLinearPCM)
        audioFileSettings[AVNumberOfChannelsKey]         = 2
        audioFileSettings[AVSampleRateKey]               = 44100.0
        audioFileSettings[AVLinearPCMBitDepthKey] = 16
        audioFileSettings[AVLinearPCMIsBigEndianKey]      = 0
        audioFileSettings[AVLinearPCMIsFloatKey]      = 0

        
        
        
        
        do {
            try self.audioFile = AVAudioFile(forWriting: recordedAudioURL, settings: audioFileSettings)
        } catch let error as NSError {
            print("Failed to create audio file")
            print(error.localizedDescription)
            
        }

        
        pitchPlayer = AVAudioPlayerNode()
        pitchPlayer.volume = 1.0
        audioEngine.attachNode(pitchPlayer)
        
        timePitch = AVAudioUnitTimePitch()
        timePitch.pitch = 1000 // In cents. The default value is 1.0. The range of values is -2400 to 2400
        audioEngine.attachNode(timePitch) //The default value is 1.0. The range of supported values is 1/32 to 32.0.
        
        audioEngine.connect(pitchPlayer, to: timePitch, format: audioFile.processingFormat)
        audioEngine.connect(timePitch, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)
        
        
        
        let inputNode = audioEngine.inputNode
        
        
        // Write the output of the input node to disk
        inputNode!.installTapOnBus(0, bufferSize: 4096,
            format: audioFile.processingFormat,
            block: { (audioPCMBuffer : AVAudioPCMBuffer!, audioTime : AVAudioTime!) in
                
                do {
                    print("Writing data to audio file...")
                    try self.audioFile.writeFromBuffer(audioPCMBuffer)
                } catch _ {
                    print("Failed to create audio file")
                }
        })
    }
    
    func startRecordingAudio() {
        do {
            try audioEngine.start()
        } catch _ {
            print("AUDIO ENGINE CATCH")
        }
    }
    
    func stopRecordingAudio() {
        audioEngine.inputNode?.removeTapOnBus(0)
//        audioEngine.stop()
        
        // Playback the audio we've captured
//        playRecordedAudio()
    }
    
    func playRecordedAudio() {
        // Setup audio engine + player
        let data = NSData(contentsOfURL: recordedAudioURL)

        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: recordedAudioURL.filePathURL!)
        }  catch let error as NSError {
                print("Failed to create audio PLAYER")
                print(error.localizedDescription)
            
        }
        
        pitchPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
//        do {
//            try audioEngine.start()
//        } catch _ {
//        }
        
        // Play the pitch audio
        pitchPlayer.play()
        
        // Save the pitch audio
        saveProcessedAudio()
//        audioPlayer.play()
    }
    
    func saveProcessedAudio() {
        
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
//            
//            let ioBufferDuration = 128.0 / 44100.0
//            
//            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(ioBufferDuration)
//            
//        } catch {
//            assertionFailure("AVAudioSession setup error: \(error)")
//        }
        
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as String
        
        let currentDateTime = NSDate();
        let formatter =  NSDateFormatter();
        formatter.dateFormat =  "ddMMyyyy-HHmmss";
        
        // NOTE: You have to use .aac, for some reason .m4a always saves an invalid file
        // The following link is also a perfect example of tapping microphone input
        // See here: http://stackoverflow.com/questions/24401609/avfoundation-malformed-m4a-file-format-using-avaudioengine-and-avaudiofile
        let recordingName = formatter.stringFromDate(currentDateTime)+".caf"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print(filePath)
        processedAudioURL = filePath
        
        
//        var audioFileSettings = Dictionary<String, AnyObject>()
//        audioFileSettings[AVFormatIDKey]                 = NSNumber(unsignedInt: kAudioFormatMPEG4AAC)
//        audioFileSettings[AVNumberOfChannelsKey]         = 1
//        audioFileSettings[AVSampleRateKey]               = 44100.0
//        audioFileSettings[AVEncoderBitRatePerChannelKey] = 16
//        audioFileSettings[AVEncoderAudioQualityKey]      = AVAudioQuality.Medium.rawValue
        
        var audioFileSettings = Dictionary<String, AnyObject>()
        audioFileSettings[AVFormatIDKey]                 = NSNumber(unsignedInt: kAudioFormatLinearPCM)
        audioFileSettings[AVNumberOfChannelsKey]         = 2
        audioFileSettings[AVSampleRateKey]               = 44100.0
        audioFileSettings[AVLinearPCMBitDepthKey] = 16
        audioFileSettings[AVLinearPCMIsBigEndianKey]      = 0
        audioFileSettings[AVLinearPCMIsFloatKey]      = 0

        
        let inputNode = audioEngine.inputNode
        
        do {
            try self.processedAudioFile = AVAudioFile(forWriting: processedAudioURL, settings: audioFileSettings)
        } catch let error as NSError {
            print("Failed to create processed audio file")
            print(error.localizedDescription)
            
        }
        
        // Write the output of the input node to disk
        audioEngine.mainMixerNode.installTapOnBus(0, bufferSize: 8192,
            format: audioFile.processingFormat,
            block: { (audioPCMBuffer : AVAudioPCMBuffer!, audioTime : AVAudioTime!) in
                
                
                if (self.processedAudioFile.length) < (self.audioFile.length){//Let us know when to stop saving the file, otherwise saving infinitely
                    
                    do {
                        print("Writing data to audio file...")
                        try self.processedAudioFile.writeFromBuffer(audioPCMBuffer)
                    } catch let error as NSError {
                        print("Failed to write to processed audio file")
                        print(error.localizedDescription)
                        
                    }
                    
                }else{
                    self.audioEngine.mainMixerNode.removeTapOnBus(0)//if we dont remove it, will keep on tapping infinitely
                    print("Did you like it? Please, vote up for my question")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.playProcessedVideo()

                    })
                }
        })
    }
    
    func playProcessedVideo() {
        print(AVAsset(URL: processedAudioURL).duration)
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: processedAudioURL.filePathURL!)
            
        } catch let error as NSError {
            print("Failed to create AVAudioPlayer")
            print(error.localizedDescription)
            
        }
        audioPlayer.delegate = self
        audioPlayer.play()
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
        
        // Start recording process
        
        // Custom audio
        setupAudioEngine()
        startRecordingAudio()
        
//        initializeAudioEngine()
        
        // Video
        recorder.record()
    }
    
    @IBAction func playAudioButtonPressed() {
        
    }
    
    func addCustomAudioSegment() {
        
        let recordSession = recorder.session
        
        // Add a segment at the end
        let segment = SCRecordSessionSegment(URL: recordedAudioURL, info: nil)
        recordSession?.addSegment(segment)
        
        // Get duration of the whole record session
        let duration = recordSession!.duration
        
        // Get a playable asset representing all the record segments
        let asset = recordSession?.assetRepresentingSegments()
        
        // Get some information about a particular segment
        let lastSegment = recordSession?.segments.last
        
        // Get duration of this segment
        print(recordSession?.segments.count)
        print(segment.duration)
    }
    
    func testAudioTools() {
        
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as String
        
        let currentDateTime = NSDate();
        let formatter =  NSDateFormatter();
        formatter.dateFormat =  "ddMMyyyy-HHmmss";
        
        // NOTE: You have to use .aac, for some reason .m4a always saves an invalid file
        // The following link is also a perfect example of tapping microphone input
        // See here: http://stackoverflow.com/questions/24401609/avfoundation-malformed-m4a-file-format-using-avaudioengine-and-avaudiofile
        let recordingName = formatter.stringFromDate(currentDateTime)+".mp4"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)

        
        let asset = AVAsset(URL: recordedAudioURL)
        let startTime = CMTimeMake(1, 10)
        let maxDuration = CMTimeMake(recorder.maxRecordDuration.value, 10)
        
        self.audioToolsTestURL = filePath
        SCAudioTools.mixAudio(asset, startTime: startTime, withVideo: recorder.session?.outputUrl, affineTransform: recorder.videoConfiguration.affineTransform, toUrl: filePath, outputFileType: AVFileTypeMPEG4, withMaxDuration: maxDuration) { (error) -> Void in
            
            self.showVideo()
        }
    }
    
    func showVideo() {
        // Create an instance of SCPlayer
        player = SCPlayer()
        player!.loopEnabled = true
        
        // Set the current playerItem using an asset representing the segments
        // of an SCRecordSession
        let data = NSData(contentsOfURL: self.audioToolsTestURL)
        player!.setItemByUrl(self.audioToolsTestURL)
        
        print(recorder.session?.outputUrl)
        
        
        // Create and add an AVPlayerLayer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = view.bounds
        
        // Start playing the asset and render it into the view
        player!.play()
    }
    
    func exportVideo() {
        
        let asset = recorder.session?.assetRepresentingSegments()
        let assetExportSession = SCAssetExportSession(asset: asset!)
        assetExportSession.delegate = self
        assetExportSession.outputUrl = recorder.session?.outputUrl
        assetExportSession.outputFileType = AVFileTypeMPEG4
        assetExportSession.videoConfiguration.preset = SCPresetLowQuality
        assetExportSession.audioConfiguration.preset = SCPresetLowQuality
        
        // TODO: FIGURE OUT OVERLAY SETTINGS
        assetExportSession.exportAsynchronouslyWithCompletionHandler { () -> Void in
            if (assetExportSession.error == nil) {
                
                self.testAudioTools()
                
                // We have our video and/or audio file
//                if let videoData = NSData(contentsOfURL: (assetExportSession.outputUrl)!) {
//                    
//                }
            } else {
                print("error exporting video")
            }
        }
        
    }
}

extension CameraViewController: AVAudioPlayerDelegate {
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
        
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer) {
        
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer, withFlags flags: Int) {
        
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer, withOptions flags: Int) {
        
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
        
        // Stop recording the custom audio
        self.stopRecordingAudio()
        self.playRecordedAudio()
//        self.addCustomAudioSegment()
//        self.testAudioTools()
//        self.exportVideo()
//        self.showVideo()
    }
    
    func recorder(recorder: SCRecorder, didBeginSegmentInSession session: SCRecordSession, error: NSError?) {
        print("begin new segment")
    }
    
    func recorder(recorder: SCRecorder, didCompleteSession session: SCRecordSession) {
        print("completed session with output url: \(recorder)")
    }
    
    func recorder(recorder: SCRecorder, didReconfigureAudioInput audioInputError: NSError?) {
        print("Reconfigured audio input: \(audioInputError)")
    }
    
    func recorder(recorder: SCRecorder, didReconfigureVideoInput videoInputError: NSError?) {
        print("Reconfigured video input: \(videoInputError)")
    }
}
