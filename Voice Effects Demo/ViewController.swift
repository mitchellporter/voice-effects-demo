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















