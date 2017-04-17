//
//  ViewController.swift
//  IASIAR
//
//  Created by Gallagher, Matthew on 1/3/17.
//  Copyright © 2017 Gallagher, Matthew. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    
    @IBOutlet var toggleButton : UIButton?
    @IBOutlet var recordButton : UIButton?
    @IBOutlet var playButton : UIButton?
    @IBOutlet var processButton : UIButton?

    var convolvedOutput : AKConvolution?
    @IBOutlet var iterations : UISlider?
    var numberOfIterations : Int = 2
    @IBOutlet var displayIterations: UILabel?
    var recorder: AKNodeRecorder?
    var iterateRecorder: AKNodeRecorder?
    var iterateFileIR: AKAudioFile?
    var tape : AKAudioFile?
    var player : AKAudioPlayer?
    var convolveMixer : AKMixer?
    var recordMixer : AKMixer?
    var sourceFile : AKAudioFile?
    var IR : AKAudioFile?
    var urlOfIR : URL?
    var IRPlayer : [AKAudioPlayer?] = []
    var iteratedIR : AKConvolution?
    var iterateMixer : AKMixer?
    var booster : AKBooster?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AKAudioFile.cleanTempDirectory()
        AKSettings.bufferLength = .veryLong
        AKSettings.playbackWhileMuted = true
        AKSettings.defaultToSpeaker = true

        //do {
        //    try AKSettings.setSession(category: .playAndRecord, with: .defaultToSpeaker)
     //
       // } catch { print("Errored setting category.") }

        sourceFile = try? AKAudioFile(readFileName: "Sitting.wav", baseDir: .resources)
        urlOfIR = Bundle.main.url(forResource: "IR", withExtension: "wav")!
        
        //player = sourceFile?.player
        //recordMixer = AKMixer(player!)
        
        //convolvedOutput = AKBitCrusher(player!,bitDepth: 4,sampleRate: 44100)
        

        
        updateIR()
        //convolvedOutput = AKConvolution(player!, impulseResponseFileURL: urlOfIR!)

        /*convolvedOutput = AKConvolution(player!, impulseResponseFileURL: IRPlayer[(numberOfIterations-1)]!.audioFile.url)
        convolveMixer = AKMixer(convolvedOutput!)
        
        recordMixer = AKMixer(convolveMixer)
        tape = try? AKAudioFile(name:"output")
        AudioKit.output = recordMixer
        AudioKit.start()
        
        print(tape!.url)
        
        
        
        
        
        convolvedOutput!.start()
        recorder = try? AKNodeRecorder(node: convolveMixer, file: tape!)
        
        */
        
        
        // Do any additional setup after loading the view, typically from a nib.
        print("End of ViewDidLoad")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateIR()
    {
        AudioKit.stop()
        player = sourceFile?.player
        recordMixer = AKMixer(player!)
        IR = try? AKAudioFile(readFileName: "ir_1_C_1.wav", baseDir: .resources)
        iterateFileIR = try? AKAudioFile(name:"temp_recording")

        for index in 0..<numberOfIterations{
            IRPlayer.append(nil)
  
            if (index==0){
                IRPlayer[index] = IR?.player
            }
            else{
                IRPlayer[index] = iterateRecorder?.audioFile?.player
            }
            iteratedIR = AKConvolution(IRPlayer[index]!, impulseResponseFileURL: urlOfIR! )
            iterateMixer = AKMixer(iteratedIR!)
            AudioKit.output = iterateMixer
            AudioKit.start()
            iteratedIR!.start()
            IRPlayer[index]!.start()
            iterateRecorder = try? AKNodeRecorder(node: iterateMixer)
            
            do{
                try iterateRecorder?.reset()
            } catch { print("Couldn't reset recording buffer")}
            
            do {
                
                try iterateRecorder?.record()
                
                
            } catch { print("Error Recording") }
            print("Recording Started")
            
            //AudioKit.output = iteratedIR
            //booster = AKBooster(IRPlayer[index]!,gain: 0)
            
                        //IRPlayer[index]!.start()
            repeat{
                
            }while iterateRecorder!.recordedDuration <= (((IRPlayer[index]?.audioFile.player!.duration)!)*2)-1
            
        AudioKit.stop()
            
            
        }

        //convolvedOutput!.stop()
        //convolvedOutput = AKConvolution(player!, impulseResponseFileURL: IRPlayer[(numberOfIterations-1)]!.audioFile.url)
        //convolvedOutput!.start()
        
        convolvedOutput = AKConvolution(player!, impulseResponseFileURL: IRPlayer[(numberOfIterations-1)]!.audioFile.url)
        convolveMixer = AKMixer(convolvedOutput!)
        
        recordMixer = AKMixer(convolveMixer)
        tape = try? AKAudioFile(name:"output")
        AudioKit.output = recordMixer
        AudioKit.start()
        
        print(tape!.url)
        
        
        
        
        
        convolvedOutput!.start()
        recorder = try? AKNodeRecorder(node: convolveMixer, file: tape!)
        
      
    }
    
    @IBAction func turnOffConvolution(_ sender: UIButton){
        
        if(convolvedOutput!.isStarted){
            convolvedOutput!.stop()
            print("Stopping Convolution")
            sender.setTitle("TURN CONVOLUTION ON", for: .normal)
        }
        else{
            convolvedOutput!.start()
            print("Starting Convolution")
            sender.setTitle("TURN CONVOLUTION OFF", for: .normal)

            }
    }

    @IBAction func recordButtonPressed(){
        
        if recorder!.isRecording {
            recorder?.stop()
            
            print("Ready to Export")
            print((recorder?.audioFile)!.fileName)
            print(tape!.fileName)
            tape!.player?.audioFile.exportAsynchronously(name: "IASIAR_output.caf", baseDir: .documents, exportFormat: .caf) {_, error in
                print("Writing the output file")
                if error != nil {
                    print("Export Failed \(error)")
                } else {
                    print("Export succeeded")
                }
            }
        }
        else {
        
        

        do{
            try recorder?.reset()
        } catch { print("Couldn't reset recording buffer")}
        
        do {

            try recorder?.record()
            
            
                    } catch { print("Error Recording") }
        print("Recording Started")
        
        }
 
    }
 

    @IBAction func updateNumIterations(_ sliderValue: UISlider){
        numberOfIterations = Int(sliderValue.value)
        displayIterations?.text = ("Number of Iterations: \(numberOfIterations)")
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton){
        
        if player!.isPlaying{
            player!.pause()
            sender.setTitle("PLAY", for: .normal)
        }
        else
        {
            player!.start()
            sender.setTitle("PAUSE", for: .normal)

        }
    }
 
}


