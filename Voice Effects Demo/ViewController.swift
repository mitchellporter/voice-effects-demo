//
//  ViewController.swift
//  Audio Mixer Demo
//
//  Created by ANDREW SMITH on 13/03/2015.
//  Copyright (c) 2015 Robot Loves You. All rights reserved.
//

import UIKit
import AVFoundation

struct RecordedAudio {
    var filePathURL: NSURL!
    var title: String!
}

class ViewController: UIViewController {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    
    var engine: AVAudioEngine!
    var playerA: AVAudioPlayerNode!
    var playerB: AVAudioPlayerNode!
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudioURL: NSURL!
    var recordedAudio: RecordedAudio!
    
    // MARK: OG PROJECT CODE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAudioRecorder()
        
        //        // Do any additional setup after loading the view, typically from a nib.
        //        engine = AVAudioEngine()
        //        playerA = AVAudioPlayerNode()
        //        playerB = AVAudioPlayerNode()
        //        playerA.volume = 0.5
        //        playerB.volume = 0.5
        //
        //        // Tsk tsk, automatically unwrapping optionals is bad form, but
        //        // this is just a demo so I'll let you off.
        //        // Here you are getting the path for the sound file you added to your project and converting it into a file url.
        //        let path = NSBundle.mainBundle().pathForResource("farah-faucet", ofType: "wav")!
        //        let url = NSURL.fileURLWithPath(path)
        //
        //        // Here you are creating an AVAudioFile from the sound file,
        //        // preparing a buffer of the correct format and length and loading
        //        // the file into the buffer.
        //        let file = try? AVAudioFile(forReading: url)
        //        let buffer = AVAudioPCMBuffer(PCMFormat: file!.processingFormat, frameCapacity: AVAudioFrameCount(file!.length))
        //        do {
        //            try file!.readIntoBuffer(buffer)
        //        } catch _ {
        //        }
        
        //        // This is a reverb with a cathedral preset. It's nice and ethereal
        //        // You're also setting the wetDryMix which controls the mix between the effect and the
        //        // original sound.
        //        let reverb = AVAudioUnitReverb()
        //        reverb.loadFactoryPreset(AVAudioUnitReverbPreset.LargeChamber)
        //        reverb.wetDryMix = 50
        //
        //        // This is a distortion with a radio tower preset which works well for speech
        //        // As distortion tends to be quite loud you're setting the wetDryMix to only 25
        //        let distortion = AVAudioUnitDistortion()
        //        distortion.loadFactoryPreset(AVAudioUnitDistortionPreset.SpeechWaves)
        //        distortion.wetDryMix = 25
        //
        //        // Attach the four nodes to the audio engine
        //        engine.attachNode(playerA)
        //        engine.attachNode(playerB)
        //        engine.attachNode(reverb)
        //        engine.attachNode(distortion)
        //
        //        // Connect playerA to the reverb
        //        engine.connect(playerA, to: reverb, format: buffer.format)
        //
        //        // Connect the reverb to the mixer
        //        engine.connect(reverb, to: engine.mainMixerNode, format: buffer.format)
        //
        //        // Connect playerB to the distortion
        //        engine.connect(playerB, to: distortion, format: buffer.format)
        //
        //        // Connect the distortion to the mixer
        //        engine.connect(distortion, to: engine.mainMixerNode, format: buffer.format)
        //
        //        // Schedule playerA and playerB to play the buffer on a loop
        //        playerA.scheduleBuffer(buffer, atTime: nil, options: AVAudioPlayerNodeBufferOptions.Loops, completionHandler: nil)
        //        playerB.scheduleBuffer(buffer, atTime: nil, options: AVAudioPlayerNodeBufferOptions.Loops, completionHandler: nil)
        //
        //        // Start the audio engine
        //        engine.prepare()
        //        do {
        //            try engine.start()
        //        } catch _ {
        //        }
        
    }
    
    // MARK: AUDIO RECORDING CODE
    func setupAudioRecorder() {
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as String
        
        let currentDateTime = NSDate();
        let formatter =  NSDateFormatter();
        formatter.dateFormat =  "ddMMyyyy-HHmmss";
        let recordingName = formatter.stringFromDate(currentDateTime)+".mp4"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print(filePath)
        recordedAudioURL = filePath
        
        // Settings
        //        I'd set AVFormatIDKey to kAudioFormatAppleIMA4, AVSampleRateKey to 16000.0, AVNumberOfChannelsKey to 1, and leave everything else at the defaults.
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch _ {
            // Do stuff
        }
        
        do {
            try audioRecorder = AVAudioRecorder(URL: recordedAudioURL, settings: [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 16000.0, AVNumberOfChannelsKey: 1])
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
        } catch _ {
            print("audio recorderr CATCH")
        }
        
    }
    
    @IBAction func recordButtonTapped() {
        
        if audioRecorder.recording {
            audioRecorder.stop()
            
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(false)
            } catch _ {
                
            }
            
        } else {
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        }
    }
    
    @IBAction func playButtonTapped(sender: UIButton) {
        playerA.play()
        playerB.play()
    }
    
    @IBAction func pauseButtonTapped(sender: UIButton) {
        playerA.pause()
        playerB.pause()
    }
    
    @IBAction func sliderChanged(sender: UISlider) {
        playerA.volume = sender.value
        playerB.volume = 1.0 - sender.value
    }
    
    @IBAction func addVoiceEffects() {
        performSegueWithIdentifier("showPlayAudio", sender: self)
    }
}

extension ViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! PlayAudioViewController
        vc.recordedAudio = self.recordedAudio
    }
}

extension ViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print("finished recording")
        
        recordedAudio = RecordedAudio()
        recordedAudio.filePathURL = recorder.url
        recordedAudio.title = recorder.url.lastPathComponent
        
    }
    
    func audioRecorderBeginInterruption(recorder: AVAudioRecorder) {
        print("beign interruption")
    }
    
    func audioRecorderEndInterruption(recorder: AVAudioRecorder) {
        print("end interruption")
    }
}















