//
//  processer.swift
//  IASIAR
//
//  Created by Gallagher, Matthew on 4/27/17.
//  Copyright © 2017 Gallagher, Matthew. All rights reserved.
//

import Foundation
import AudioKit

class Processer {
        
    var convolvedOutput : AKConvolution?
    var numberOfIterations : Int = 2
    
    var recorder: AKNodeRecorder?
    var iterateRecorder: AKNodeRecorder?
    var sourceRecorder: AKNodeRecorder?
    var IRRecorder: AKNodeRecorder?
    var micMixer: AKMixer?
    var micBooster: AKBooster?
    var micSource: AKMicrophone?
    var UGSource: AKAudioFile?
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
    var useUGSource : Bool = false
    
    init(){
        
        AKAudioFile.cleanTempDirectory()
        AKSettings.bufferLength = .veryLong
        AKSettings.playbackWhileMuted = true
        AKSettings.audioInputEnabled = true
        
        try? AKSettings.setSession(category: .playAndRecord, with: .defaultToSpeaker)
        
        sourceFile = try? AKAudioFile(readFileName: "Sitting.wav", baseDir: .resources)
        urlOfIR = Bundle.main.url(forResource: "grange", withExtension: "wav")!
        
        
    }

    
    func update(completion: @escaping ((_ result:Bool?)-> Void)){
        
            
            DispatchQueue.global(qos: .background).async {
                print("This is run on the background queue")
                
                
                AudioKit.stop()
                if(self.useUGSource)
                {
                    self.urlOfIR = self.IR?.url
                }
                else{
                    self.urlOfIR = Bundle.main.url(forResource: "grange", withExtension: "wav")!
                }
                
                self.player = self.sourceFile?.player
                
                print(self.player)
                self.recordMixer = AKMixer(self.player!)
                print(self.IR)
                if(!self.useUGSource)
                {
                    self.IR = try? AKAudioFile(readFileName: "grange.wav", baseDir: .resources)
                    print(self.IR)
                }
            /*    if(self.IR?.maxLevel == Float.leastNormalMagnitude)
                {
                    print("WARNING: IR file is silent or too quiet")
                }
                
              //
                
                do {
                    try self.normalizedIR = self.IR?.normalized()
                } catch { print("Error Normalizing")}
                */
                self.iterateFileIR = try? AKAudioFile(name:"temp_recording")
                
                for index in 0..<self.numberOfIterations{
                    self.IRPlayer.append(nil)
                    
                    if (index==0){
                        //self.IRPlayer[index] = self.NormalizedIR?.player
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
                    
                    repeat{
                        
                    }while self.iterateRecorder!.recordedDuration <= (((self.IRPlayer[index]?.duration)!)+(self.IRPlayer[0]?.duration)!)-1
                    
                    AudioKit.stop()
                    
                    
                    self.selectedIteration = self.numberOfIterations
                    
                    
                    
                }
                
                
                self.convolvedOutput = AKConvolution(self.player!, impulseResponseFileURL: self.IRPlayer[(self.numberOfIterations-1)]!.audioFile.url)
                self.convolveMixer = AKMixer(self.convolvedOutput!)
                self.micSource = AKMicrophone()
                self.micMixer = AKMixer(self.micSource)
                self.micBooster = AKBooster(self.micMixer)
                self.micBooster!.gain = 0
                
                self.recordMixer = AKMixer(self.convolveMixer, self.micMixer!)
                self.tape = try? AKAudioFile(name:"output")
                self.UGSource = try? AKAudioFile(name:"newSource")
                AudioKit.output = self.recordMixer
                AudioKit.start()
                
                self.convolvedOutput!.start()
                self.recorder = try? AKNodeRecorder(node: self.convolveMixer, file: self.tape!)
                self.sourceRecorder = try? AKNodeRecorder(node: self.micMixer, file: self.UGSource!)
                self.IRRecorder = try? AKNodeRecorder(node: self.micMixer, file: self.UGSource!)

                
                
                
                
                DispatchQueue.main.async {
                          print("This is run on the main queue, after the previous code in outer block")
                        completion(true)

                    
                     }

                                }
        

    }
    
    
    func record(){
        if recorder!.isRecording {
            recorder?.stop()
            
            print("Ready to Export")
            
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
    
    func sourceRecord(){
        if(sourceRecorder!.isRecording){
            sourceRecorder?.stop()
            
            print("Finished Recording")
            useUGSource = true
            UGSource!.player?.audioFile.exportAsynchronously(name: "new_source.caf", baseDir: .documents, exportFormat: .caf) {_, error in
                print("Writing the output file")
                if error != nil {
                    print("Export Failed \(error)")
                } else {
                    print("Export succeeded")
                }
            }
           
            //update(completion: { (result) -> Void in
            //    print("Reloading IR and Source")
            //})
            sourceFile = UGSource
            loadSelectedIteration()

            
        }
        else {
            
            
            //AudioKit.stop()
            //AudioKit.output = micMixer
            //AudioKit.start()
            sourceRecorder = try? AKNodeRecorder(node: micMixer, file: UGSource!)
            do{
                try sourceRecorder?.reset()
            } catch { print("Couldn't reset recording buffer")}
            
            do {
                
                try sourceRecorder?.record()
                
                
            } catch { print("Error Recording") }
            print("Recording Started")
            
        }
    }
    func IRRecord(){
        if(IRRecorder!.isRecording){
            IRRecorder?.stop()
            
            print("Finished Recording")
            useUGSource = true
            UGSource!.player?.audioFile.exportAsynchronously(name: "new_IR.caf", baseDir: .documents, exportFormat: .caf) {_, error in
                print("Writing the output file")
                if error != nil {
                    print("Export Failed \(error)")
                } else {
                    print("Export succeeded")
                }
            }
           
            IR = UGSource
            update(completion: { (result) -> Void in
                print("Reloading IR and Source")
            })
            
            
            
            
        }
        else {
            
            
            //AudioKit.stop()
            //AudioKit.output = micMixer
            //AudioKit.start()
            IRRecorder = try? AKNodeRecorder(node: micMixer, file: UGSource!)
            do{
                try IRRecorder?.reset()
            } catch { print("Couldn't reset recording buffer")}
            
            do {
                
                try IRRecorder?.record()
                
                
            } catch { print("Error Recording") }
            print("Recording Started")
            
        }
    }

    
    func play(){
    
    if player!.isPlaying{
        player!.pause()
                }
    else
    {
        player!.start()
       
        }
    }
    
    func loadSelectedIteration(){
        
        AudioKit.stop()
        player = sourceFile?.player
        recordMixer = AKMixer(player!)
       // IR = try? AKAudioFile(readFileName: "grange.wav", baseDir: .resources)
        convolvedOutput = AKConvolution(player!, impulseResponseFileURL: IRPlayer[(selectedIteration-1)]!.audioFile.url)
        convolveMixer = AKMixer(convolvedOutput!)
        
        recordMixer = AKMixer(convolveMixer)
        tape = try? AKAudioFile(name:"output")
        AudioKit.output = recordMixer
        AudioKit.start()
        
        convolvedOutput!.start()
        recorder = try? AKNodeRecorder(node: convolveMixer, file: tape!)
    }
}
