//
//  PlayAudioViewController.swift
//  Audio Mixer Demo
//
//  Created by Mitchell Porter on 3/11/16.
//  Copyright © 2016 Robot Loves You. All rights reserved.
//

import UIKit
import AVFoundation

class PlayAudioViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer!
    var recordedAudio: RecordedAudio!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        audioEngine = AVAudioEngine()
        
        audioPlayer = try? AVAudioPlayer(contentsOfURL: recordedAudio.filePathURL)
        audioPlayer.volume = 1.0
        audioPlayer.enableRate = true;
        
        audioFile = try? AVAudioFile(forReading: recordedAudio.filePathURL)
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func playChipmunk(sender: UIButton) {
        
        playPitch(1000)
    }
    
    @IBAction func playDarthVader(sender: UIButton) {
        
        playPitch(-1000)
    }
    
    @IBAction func playFast(sender: UIButton) {
        audioPlayer.rate=2.0
        audioPlayer.play()
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        audioPlayer.stop()
    }
    @IBAction func playSlow(sender: UIButton) {
        audioPlayer.rate=0.5;
        audioPlayer.play();
        
    }
    
    func playPitch(pitch: Float)
    {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        let pitchPlayer = AVAudioPlayerNode()
        audioEngine.attachNode(pitchPlayer)
        
        let timePitch = AVAudioUnitTimePitch()
        timePitch.pitch = pitch
        audioEngine.attachNode(timePitch)
        
        audioEngine.connect(pitchPlayer, to: timePitch, format: nil)
        audioEngine.connect(timePitch, to: audioEngine.outputNode, format: nil)
        
        pitchPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        do {
            try audioEngine.start()
        } catch _ {
        }
        pitchPlayer.play()
    }
}
