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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sourceFile = try? AKAudioFile(readFileName: "Sitting.wav", baseDir: .resources)
        let urlOfIR = Bundle.main.url(forResource: "IR", withExtension: "wav")!
        let player = sourceFile?.player
        
        convolvedOutput = AKConvolution(player!, impulseResponseFileURL: urlOfIR)
        
        AudioKit.output = convolvedOutput!
        AudioKit.start()
       
        convolvedOutput!.start()
        player!.start()
        //player!.start()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func turnOffConvolution(){
        if(convolvedOutput!.isStarted){

            convolvedOutput!.stop()

        }
        else{
            convolvedOutput!.start()
        }
        print("Turning Off Convolution")
    }


}

