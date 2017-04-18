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
    @IBOutlet var loadIterationButton : UIButton?
    @IBOutlet var stepper : UIStepper?
    @IBOutlet var displaySelectedIteration : UILabel?
    @IBOutlet var processingIndicator : UIActivityIndicatorView?
    
    

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
    var normalizedIR : AKAudioFile?
    var selectedIteration : Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AKAudioFile.cleanTempDirectory()
        AKSettings.bufferLength = .veryLong
        AKSettings.playbackWhileMuted = true
        AKSettings.defaultToSpeaker = true


        sourceFile = try? AKAudioFile(readFileName: "Sitting.wav", baseDir: .resources)
        urlOfIR = Bundle.main.url(forResource: "ir_1_C_1", withExtension: "wav")!
        
        updateIR()

        convolvedOutput!.start()
        recorder = try? AKNodeRecorder(node: convolveMixer, file: tape!)
        
        // Do any additional setup after loading the view, typically from a nib.
        print("End of ViewDidLoad")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateIR()
    {
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            
            AudioKit.stop()
            self.player = self.sourceFile?.player
            self.recordMixer = AKMixer(self.player!)
            self.IR = try? AKAudioFile(readFileName: "IR.wav", baseDir: .resources)
            if(self.IR?.maxLevel == Float.leastNormalMagnitude)
            {
                print("WARNING: IR file is silent or too quiet")
            }
            print (self.IR!.maxLevel)
            
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
                
                
                self.processButton?.setTitle("Processing", for: .normal)
                self.processingIndicator?.startAnimating()
            }

            do {
                try self.normalizedIR = self.IR!.normalized()
            } catch { print("Error Normalizing")}
            
            self.iterateFileIR = try? AKAudioFile(name:"temp_recording")
            
            for index in 0..<self.numberOfIterations{
                self.IRPlayer.append(nil)
                
                if (index==0){
                    self.IRPlayer[index] = self.IR?.player
                }
                else{
                    self.IRPlayer[index] = self.iterateRecorder?.audioFile?.player
                }
                self.iteratedIR = AKConvolution(self.IRPlayer[index]!, impulseResponseFileURL: self.urlOfIR! )
                self.iterateMixer = AKMixer(self.iteratedIR!)
                AudioKit.output = self.iterateMixer
                AudioKit.start()
                self.iteratedIR!.start()
                self.IRPlayer[index]!.start()
                self.iterateRecorder = try? AKNodeRecorder(node: self.iterateMixer)
                
                do{
                    try self.iterateRecorder?.reset()
                } catch { print("Couldn't reset recording buffer")}
                
                do {
                    
                    try self.iterateRecorder?.record()
                    
                    
                } catch { print("Error Recording") }
                print("Recording Started")
                
                //AudioKit.output = iteratedIR
                //booster = AKBooster(IRPlayer[index]!,gain: 0)
                
                //IRPlayer[index]!.start()
                repeat{
                    
                }while self.iterateRecorder!.recordedDuration <= (((self.IRPlayer[index]?.audioFile.player!.duration)!)+(self.IRPlayer[0]?.audioFile.player!.duration)!)-1
                
                AudioKit.stop()
                
                
                self.selectedIteration = self.numberOfIterations
                self.stepper?.value = Double(self.numberOfIterations)
                self.stepper?.maximumValue = Double(self.numberOfIterations)
                self.displaySelectedIteration?.text = String(self.selectedIteration)
                
                
            }
            
            //convolvedOutput!.stop()
            //convolvedOutput = AKConvolution(player!, impulseResponseFileURL: IRPlayer[(numberOfIterations-1)]!.audioFile.url)
            //convolvedOutput!.start()
            
            self.convolvedOutput = AKConvolution(self.player!, impulseResponseFileURL: self.IRPlayer[(self.numberOfIterations-1)]!.audioFile.url)
            self.convolveMixer = AKMixer(self.convolvedOutput!)
            
            self.recordMixer = AKMixer(self.convolveMixer)
            self.tape = try? AKAudioFile(name:"output")
            AudioKit.output = self.recordMixer
            AudioKit.start()
            
            print(self.tape!.url)
            
            
            
            
            
            self.convolvedOutput!.start()
            self.recorder = try? AKNodeRecorder(node: self.convolveMixer, file: self.tape!)
            self.processButton?.setTitle("Process Iterations", for: .normal)

            self.processingIndicator?.stopAnimating()
            print("Done")
            
                    }
      
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
    
    @IBAction func loadIteration(){
        AudioKit.stop()
        player = sourceFile?.player
        recordMixer = AKMixer(player!)
        IR = try? AKAudioFile(readFileName: "ir_1_C_1.wav", baseDir: .resources)
        convolvedOutput = AKConvolution(player!, impulseResponseFileURL: IRPlayer[(selectedIteration-1)]!.audioFile.url)
        convolveMixer = AKMixer(convolvedOutput!)
        
        recordMixer = AKMixer(convolveMixer)
        tape = try? AKAudioFile(name:"output")
        AudioKit.output = recordMixer
        AudioKit.start()
        
        print(tape!.url)
        
        playButton?.setTitle("PLAY", for: .normal)
        
        
        
        convolvedOutput!.start()
        recorder = try? AKNodeRecorder(node: convolveMixer, file: tape!)
    }
 
    @IBAction func updateSelectedIteration(_ sender: UIStepper){
        selectedIteration = Int(sender.value)
        displaySelectedIteration?.text = String(selectedIteration)
    }
}


