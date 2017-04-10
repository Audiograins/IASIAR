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
    var convolvedOutput : AKConvolution?
    var convolvedOutput2 : AKConvolution?
    @IBOutlet var iterations : UISlider?
    var numberOfIterations : Int = 0
    //@IBAction func updateNumIterations(sender: UISlider)
    @IBOutlet var displayIterations: UILabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sourceFile = try? AKAudioFile(readFileName: "Sitting.wav", baseDir: .resources)
        let urlOfIR = Bundle.main.url(forResource: "IR", withExtension: "wav")!
        let urlOfIteratedIR = Bundle.main.url(forResource: "IR", withExtension: "wav")! // placeholder
        let IRsourceFile = try? AKAudioFile(readFileName: "IR.wav", baseDir: .resources)
        let player = sourceFile?.player
        var IRPlayer : AKAudioPlayer
        if let IRPlayerTest = IRsourceFile?.player{
            IRPlayer = IRPlayerTest
            print("Hi")
        }
        var numberOfIterations : Int
        //updateIR()
        convolvedOutput = AKConvolution(player!, impulseResponseFileURL: urlOfIteratedIR)

        AudioKit.output = convolvedOutput!
        AudioKit.start()
       
        convolvedOutput!.start()
        player!.start()
        //player!.start()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        print("Hello")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }
    
    /*func updateIR(IRPlayer: AKAudioPlayer)
    {
        let urlOfIR = Bundle.main.url(forResource: "IR", withExtension: "wav")!
        let iteratedIR = AKConvolution(IRPlayer, impulseResponseFileURL: urlOfIR )
        
    }
    */
    @IBAction func turnOffConvolution(){
        if(convolvedOutput!.isStarted){

            convolvedOutput!.stop()

        }
        else{
            var IRiteration = convolvedOutput
           // let urlOfIR = Bundle.main.url(forResource: "IR", withExtension: "wav")!
           // for index in 1...5 {
           //     IRiteration = AKConvolution(IRiteration!, impulseResponseFileURL: urlOfIR)
           // }

            convolvedOutput!.start()
        }
        print("Turning Off Convolution")
    }


    @IBAction func updateNumIterations(sliderValue: UISlider){
        numberOfIterations = Int(sliderValue.value)
        displayIterations?.text = ("Number of Iterations: \(numberOfIterations)")
    }
}

