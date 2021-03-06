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
    @IBOutlet var recordSourceButton : UIButton?
    @IBOutlet var recordIRButton : UIButton?

    @IBOutlet var iterations : UISlider?
    @IBOutlet var displayIterations: UILabel?
    
    var processer = Processer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButtonBorder(sender: toggleButton)
        addButtonBorder(sender: processButton)
        addButtonBorder(sender: loadIterationButton)
        addButtonBorder(sender: playButton)
        addButtonBorder(sender: recordButton)
        addButtonBorder(sender: recordSourceButton)
        addButtonBorder(sender: recordIRButton)



        updateIR()
        
        // Do any additional setup after loading the view, typically from a nib.
        print("End of ViewDidLoad")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateIR()
    {
        playButton?.setTitle("PLAY", for: .normal)
        playButton?.setTitleColor(UIColor.gray, for: .disabled)
        playButton?.isEnabled = false
        
        recordButton?.setTitleColor(UIColor.gray, for: .disabled)
        recordButton?.isEnabled = false
        
        recordSourceButton?.setTitleColor(UIColor.gray, for: .disabled)
        recordSourceButton?.isEnabled = false
        
        stepper?.isEnabled = false
        
        processButton?.setTitleColor(UIColor.gray, for: .disabled)
        processButton?.isEnabled = false
        
        loadIterationButton?.setTitleColor(UIColor.gray, for: .disabled)
        loadIterationButton?.isEnabled = false
        
        toggleButton?.setTitleColor(UIColor.gray, for: .disabled)
        toggleButton?.isEnabled = false
        
        processButton?.setTitle("Processing", for: .normal)
        processingIndicator?.startAnimating()
        processer.update(completion: { (result) -> Void in
            self.processButton?.setTitle("Process Iterations", for: .normal)
            self.processingIndicator?.stopAnimating()
            self.stepper?.value = Double(self.processer.numberOfIterations)
            self.stepper?.maximumValue = Double(self.processer.numberOfIterations)
            self.displaySelectedIteration?.text = String(self.processer.selectedIteration)
            self.playButton?.isEnabled = true
            self.recordButton?.isEnabled = true
            self.recordSourceButton?.isEnabled = true
            self.loadIterationButton?.isEnabled = true
            self.toggleButton?.isEnabled = true
            self.stepper?.isEnabled = true
            self.stepper?.value = Double(self.processer.numberOfIterations)
            let stringToDisplay = String(format: "%02d", self.processer.selectedIteration)
            self.loadIterationButton?.setTitle("Load Iteration # " + stringToDisplay, for: .normal)
            self.processButton?.isEnabled = true
        })
        
    }
    
    @IBAction func turnOffConvolution(_ sender: UIButton){
        
        if(processer.convolvedOutput!.isStarted){
            processer.convolvedOutput!.stop()
            print("Stopping Convolution")
            sender.setTitle("TURN CONVOLUTION ON", for: .normal)
        }
        else{
            processer.convolvedOutput!.start()
            print("Starting Convolution")
            sender.setTitle("TURN CONVOLUTION OFF", for: .normal)

            }
    }

    @IBAction func recordButtonPressed(){
        
        processer.record()
 
    }
    
    @IBAction func sourceRecordButtonPressed(_ sender: UIButton){
        
        processer.sourceRecord()
        if(processer.sourceRecorder!.isRecording){
            sender.setTitle("Recording Source", for: .normal)
        }
        else{
            sender.setTitle("Record New Source", for: .normal)
        }
    }
    
    @IBAction func IRRecordButtonPressed(_ sender: UIButton){
        
        processer.IRRecord()
        if(processer.IRRecorder!.isRecording){
            sender.setTitle("Recording IR", for: .normal)
        }
        else{
            sender.setTitle("Record New IR", for: .normal)
        }
    }
 

    @IBAction func updateNumIterations(_ sliderValue: UISlider){
        processer.numberOfIterations = Int(sliderValue.value)
        displayIterations?.text = ("Number of Iterations: \(processer.numberOfIterations)")
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton){
        
        if processer.player!.isPlaying{
            sender.setTitle("PLAY", for: .normal)
        }
        else
        {
            sender.setTitle("PAUSE", for: .normal)
        }
        processer.play()
        
    }
    
    @IBAction func loadIteration(){
        
        processer.loadSelectedIteration()
        playButton?.setTitle("PLAY", for: .normal)

    }
 
    @IBAction func updateSelectedIteration(_ sender: UIStepper){
        processer.selectedIteration = Int(sender.value)
        let stringToDisplay = String(format: "%02d", processer.selectedIteration)
        loadIterationButton?.setTitle("Load Iteration # " + stringToDisplay, for: .normal)    }
    
    func addButtonBorder(sender:UIButton!){
        sender.layer.borderWidth = 1
        sender.layer.borderColor = UIColor.black.cgColor
        sender.layer.cornerRadius = 5
        sender.layer.shadowColor = UIColor.darkGray.cgColor
        sender.layer.shadowOpacity = 0.8
        sender.layer.shadowOffset = CGSize(width:2,height:2)
    }
}


