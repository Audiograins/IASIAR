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
    
    @IBOutlet var processButton : UIButton?
    @IBOutlet var recordButton : UIButton?
    var convolvedOutput : AKBitCrusher?
    @IBOutlet var iterations : UISlider?
    var numberOfIterations : Int = 0
    @IBOutlet var displayIterations: UILabel?
    var recorder: AKNodeRecorder?
    var tape : AKAudioFile?
    var player : AKAudioPlayer?
    var convolveMixer : AKMixer?
    var recordMixer : AKMixer?
    var sourceFile : AKAudioFile?
    var urlOfIR : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AKAudioFile.cleanTempDirectory()
        AKSettings.bufferLength = .veryLong
        AKSettings.playbackWhileMuted = true

        do {
            try AKSettings.setSession(category: .playAndRecord, with: .defaultToSpeaker)
     
        } catch { print("Errored setting category.") }


        sourceFile = try? AKAudioFile(readFileName: "Sitting.wav", baseDir: .resources)
        urlOfIR = Bundle.main.url(forResource: "IR", withExtension: "wav")!
    
        player = sourceFile?.player
        
        convolvedOutput = AKBitCrusher(player!,bitDepth: 4,sampleRate: 44100)
        //convolvedOutput = AKConvolution(player!, impulseResponseFileURL: urlOfIR)
        convolveMixer = AKMixer(convolvedOutput!)
        
                //recordMixer = AKMixer(convolveMixer)
        
        tape = try? AKAudioFile()
        print(tape!.url)
       
    
        
        AudioKit.output = convolveMixer
        AudioKit.start()
        recorder = try? AKNodeRecorder(node: convolveMixer, file: tape!)
        
        //convolvedOutput!.start()
        player!.start()
        
        // Do any additional setup after loading the view, typically from a nib.
        print("End of ViewDidLoad")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }
    
    func updateIR(_ IRPlayer: AKAudioPlayer)
    {
        let urlOfIR = Bundle.main.url(forResource: "IR", withExtension: "wav")!
        let iteratedIR = AKConvolution(IRPlayer, impulseResponseFileURL: urlOfIR )
        
    }
    
    @IBAction func turnOffConvolution(){
        
        if(convolvedOutput!.isStarted){
            convolvedOutput!.stop()
            print("Stopping Convolution")
        }
        else{
            convolvedOutput!.start()
            print("Starting Convolution")
            }
    }

    @IBAction func recordButtonPressed(){
        
        if recorder!.isRecording {
            recorder?.stop()
            
            print("Ready to Export")
            tape!.exportAsynchronously(name: "IASIAR_output.caf", baseDir: .documents, exportFormat: .caf) {_, error in
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
 
}

