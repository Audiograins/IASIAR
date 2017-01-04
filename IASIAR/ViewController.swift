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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sourceFile = try? AKAudioFile(readFileName: "Sitting.wav", baseDir: .resources)
        let IRFile = Bundle.main.path(forResource: "IR", ofType: "wav")
        let urlOfIR = NSURL.fileURL(withPath: IRFile!)
        let player = sourceFile?.player
        
        let convolvedOutput = AKConvolution(player!, impulseResponseFileURL: urlOfIR)
        
        AudioKit.output = convolvedOutput
        AudioKit.start()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }


}

