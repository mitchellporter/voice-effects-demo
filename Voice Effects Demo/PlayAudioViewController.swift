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
    var recordedAudio: RecordedAudio?
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    
    var currentPitch: Float = 1.0
    var currentRate: Float = 1.0
    var currentVolume: Float = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if recordedAudio == nil {
            let path = NSBundle.mainBundle().pathForResource("farah-faucet.wav", ofType: nil)
            recordedAudio = RecordedAudio()
            recordedAudio!.filePathURL = NSURL(fileURLWithPath: path!)
        }
        
        // Setup audio engine + player
        audioEngine = AVAudioEngine()
        audioPlayer = try? AVAudioPlayer(contentsOfURL: recordedAudio!.filePathURL)
        audioPlayer.numberOfLoops = 100 // Negative value = infinite loops
        audioPlayer.volume = 50.0
        audioPlayer.enableRate = true
        
        audioFile = try? AVAudioFile(forReading: recordedAudio!.filePathURL)
        
        self.play()
        
        
        // Do any additional setup after loading the view.
        
        
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
    
    @IBAction func volumeChanged(sender: UISlider) {
        currentVolume = sender.value
    }
    
    @IBAction func pitchChanged(sender: UISlider) {
        currentPitch = sender.value
    }
    
    @IBAction func rateChanged(sender: UISlider) {
        currentRate = sender.value
    }

    
    @IBAction func playChipmunk(sender: UIButton) {
        currentPitch = 1000
        play()
    }
    
    @IBAction func playDarthVader(sender: UIButton) {
        currentPitch = -1200
        play()
    }
    
    @IBAction func flamboyantEffect() {
        currentPitch = -500
        play()
    }
    
    @IBAction func playTesting() {
        
    }
    
    @IBAction func playFast(sender: UIButton) {
        audioPlayer.rate = 2.0
        audioPlayer.play()
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        audioPlayer.stop()
    }
    @IBAction func playSlow(sender: UIButton) {
        audioPlayer.rate = 0.5;
        audioPlayer.play();
    }
    
    func play() {
        
        // 1. Create nodes
        
        // 2. Attach nodes to engine
        
        // 3. Connect nodes
        
        // 4. Last node connects to mainMixerNode
        
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        let pitchPlayer = AVAudioPlayerNode()
        pitchPlayer.volume = 50
        audioEngine.attachNode(pitchPlayer)
        
        let timePitch = AVAudioUnitTimePitch()
        timePitch.pitch = currentPitch // In cents. The default value is 1.0. The range of values is -2400 to 2400
//        timePitch.rate = 2;
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
}
