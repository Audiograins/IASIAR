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
    var convolvedOutput : AKConvolution!
    @IBOutlet var iterations : UISlider?
    var numberOfIterations : Int = 0
    @IBOutlet var displayIterations: UILabel?
    var recorder: AKNodeRecorder?
    var file : AKAudioFile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        do {
            try AKSettings.setSession(category: .playAndRecord, with: .defaultToSpeaker)
            
        } catch { print("Errored setting category.") }

        AKAudioFile.cleanTempDirectory()
        AKSettings.bufferLength = .longest
        
        let sourceFile = try? AKAudioFile(readFileName: "Sitting.wav", baseDir: .resources)
        let urlOfIR = Bundle.main.url(forResource: "IR", withExtension: "wav")!
    
        let player = sourceFile?.player
        player?.looping = true
        
        convolvedOutput = AKConvolution(player, impulseResponseFileURL: urlOfIR)
        
        
        
        AudioKit.output = convolvedOutput
        file = try! AKAudioFile(name: "test_output")
        recorder = try! AKNodeRecorder(node:player!, file: file)
        AudioKit.start()
        
        convolvedOutput.start()
        
        player!.start()
        
        do {
            print("1")
            try recorder?.record()
            print("2")
        } catch { print("Error Recording") }
        print("Recording Started")

        
        /*player?.audioFile.exportAsynchronously(name: "TempTestFile.m4a", baseDir: .documents, exportFormat: .m4a) {_, error in
            if error != nil {
                print("Export Failed \(error)")
            } else {
                print("Export succeeded")
            }
        }
 */
        /*try convolvedOutput?.audioFile.exportAsynchronously(name: "convolved",
                                                 baseDir: .documents,
                                                 exportFormat: .wav) { exportedFile, error in
        print("myExportCallback has been triggered so export has ended")
                                                    if error == nil {
                                                            print("Export Succeeded")
                                                    }
                                                    else {
                                                        print("Export Failed: \(error)")
                                                    }
        */
 
        //player!.start()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        print("Hello")
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
        if(convolvedOutput.isStarted){

            convolvedOutput.stop()
            recorder!.stop()
            /*print("Ready to Export")
            file?.exportAsynchronously(name: "TempTestFile.m4a", baseDir: .documents, exportFormat: .m4a) {_, error in
                print("Writing the output file")
                if error != nil {
                    print("Export Failed \(error)")
                } else {
                    print("Export succeeded")
                }
            }
*/

        }
        else{
           
            convolvedOutput!.start()
        }
        print("Turning Off Convolution")
    }


    @IBAction func updateNumIterations(_ sliderValue: UISlider){
        numberOfIterations = Int(sliderValue.value)
        displayIterations?.text = ("Number of Iterations: \(numberOfIterations)")
    }
}

