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
    
    init(){
        
        AKAudioFile.cleanTempDirectory()
        AKSettings.bufferLength = .veryLong
        AKSettings.playbackWhileMuted = true
        
        try? AKSettings.setSession(category: .playAndRecord, with: .defaultToSpeaker)
        
        sourceFile = try? AKAudioFile(readFileName: "Sitting.wav", baseDir: .resources)
        urlOfIR = Bundle.main.url(forResource: "grange", withExtension: "wav")!
        
        
    }

    
    func update(completion: ((_ result:Bool?)-> Void)){
        
            
            DispatchQueue.global(qos: .background).async {
                print("This is run on the background queue")
                
                
                AudioKit.stop()
                self.urlOfIR = Bundle.main.url(forResource: "grange", withExtension: "wav")!
                
                self.player = self.sourceFile?.player
                self.recordMixer = AKMixer(self.player!)
                self.IR = try? AKAudioFile(readFileName: "grange.wav", baseDir: .resources)
                if(self.IR?.maxLevel == Float.leastNormalMagnitude)
                {
                    print("WARNING: IR file is silent or too quiet")
                }
                
              //  DispatchQueue.main.async {
              //      print("This is run on the main queue, after the previous code in outer block")
              //
                    
               // }
                
                do {
                    try self.normalizedIR = self.IR?.normalized()
                } catch { print("Error Normalizing")}
                
                self.iterateFileIR = try? AKAudioFile(name:"temp_recording")
                
                for index in 0..<self.numberOfIterations{
                    self.IRPlayer.append(nil)
                    
                    if (index==0){
                        self.IRPlayer[index] = self.normalizedIR?.player
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
                
                self.recordMixer = AKMixer(self.convolveMixer)
                self.tape = try? AKAudioFile(name:"output")
                AudioKit.output = self.recordMixer
                AudioKit.start()
                
                self.convolvedOutput!.start()
                self.recorder = try? AKNodeRecorder(node: self.convolveMixer, file: self.tape!)
        
        
                                }
        
        completion(true)

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
        IR = try? AKAudioFile(readFileName: "grange.wav", baseDir: .resources)
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
