import AVFoundation
import Accelerate
import SwiftUI

/**
 - I'm no expert in audio processing. What I did here, I learnt from this Article:
   - __Audio Visualization in Swift Using Metal and Accelerate__
   - _By Alex Barbulescu_
   - https://betterprogramming.pub/audio-visualization-in-swift-using-metal-accelerate-part-1-390965c095d7
 
 This works for the purposes of this demo, but if you want to add a sound visualizer to a real app,
 consider using something more robust, like the [AudioKit](https://audiokit.io/) framework.
 
 
 */
enum Constants {
    static let updateInterval = 0.03
    static let barAmount = 40
    static let magnitudeLimit: Float = 32
}


class mainViewModel: ObservableObject {
    @Published var isPlaying: Bool = false
    
    private let engine = AVAudioEngine()
    private let bufferSize = 1024
    
    @Published var data: [Float] = Array(repeating: 0, count: Constants.barAmount)
        .map { _ in Float.random(in: 1 ... Constants.magnitudeLimit) }
    
    let player = AVAudioPlayerNode()
    var fftMagnitudes: [Float] = []
    
    func replaying() {
        guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        do {
            // Append the file name (m4a file) to the Document directory URL
            let fileURL = documentDirectoryURL.appendingPathComponent("test.m4a")
            
            _ = engine.mainMixerNode
            
            engine.prepare()
            try engine.start()
            
            let audioFile = try AVAudioFile(
                forReading: fileURL
            )
            
            let format = audioFile.processingFormat
            
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: format)
            
            player.scheduleFile(audioFile, at: nil) {
                audioFile.framePosition = 0
                self.player.play()
            }
            
            let fftSetup = vDSP_DFT_zop_CreateSetup(
                nil,
                UInt(bufferSize),
                vDSP_DFT_Direction.FORWARD
            )
            
            engine.mainMixerNode.installTap(
                onBus: 0,
                bufferSize: UInt32(bufferSize),
                format: nil
            ) { [self] buffer, _ in
                let channelData = buffer.floatChannelData?[0]
                fftMagnitudes = fft(data: channelData!, setup: fftSetup!)
            }
        } catch {
            print(error)
        }
    }
    
    func updateData(_: Date) {
        if self.isPlaying {
            withAnimation(.easeOut(duration: 0.08)) {
                data = self.fftMagnitudes.map {
                    min($0, Constants.magnitudeLimit)
                }
            }
        }
    }
    
    func playButtonTapped() {
        if self.isPlaying {
            self.player.pause()
        } else {
            self.player.play()
        }
        self.isPlaying.toggle()
    }
    
    func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float] {
        var realIn = [Float](repeating: 0, count: bufferSize)
        var imagIn = [Float](repeating: 0, count: bufferSize)
        var realOut = [Float](repeating: 0, count: bufferSize)
        var imagOut = [Float](repeating: 0, count: bufferSize)
            
        for i in 0 ..< bufferSize {
            realIn[i] = data[i]
        }
        
        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)
        
        var magnitudes = [Float](repeating: 0, count: Constants.barAmount)
        
        realOut.withUnsafeMutableBufferPointer { realBP in
            imagOut.withUnsafeMutableBufferPointer { imagBP in
                var complex = DSPSplitComplex(realp: realBP.baseAddress!, imagp: imagBP.baseAddress!)
                vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(Constants.barAmount))
            }
        }
        
        var normalizedMagnitudes = [Float](repeating: 0.0, count: Constants.barAmount)
        var scalingFactor = Float(1)
        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, UInt(Constants.barAmount))
            
        return normalizedMagnitudes
    }
}


