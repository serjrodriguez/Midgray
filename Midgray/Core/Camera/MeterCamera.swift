//
//  MeterCamera.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 23/11/26.
//

import Foundation
import AVFoundation

actor MeterCamera: LightSensing {
    nonisolated func readings() -> AsyncStream<CameraReading> {
        AsyncStream { continuation in
            let task = Task { await self.run(continuation) }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
    
    private func run(_ continuation: AsyncStream<CameraReading>.Continuation) async {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device)
                else {
            continuation.finish()
            return
        }
        
        let session = AVCaptureSession()
        guard session.canAddInput(input) else {
            continuation.finish()
            return
        }
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        guard session.canAddOutput(output) else {
            continuation.finish()
            return
        }
        session.addOutput(output)
        
        if device.exposureMode != .continuousAutoExposure, (try? device.lockForConfiguration()) != nil {
            device.exposureMode = .continuousAutoExposure
            device.unlockForConfiguration()
        }
        
        session.startRunning()
        
        while !Task.isCancelled {
            let reading = CameraReading(
                aperture: Double(device.lensAperture),
                exposureTime: CMTimeGetSeconds(device.exposureDuration),
                iso: Double(device.iso),
                exposureTargetOffset: Double(device.exposureTargetOffset)
            )
            continuation.yield(reading)
            try? await Task.sleep(for: .milliseconds(100))
        }
        
        session.stopRunning()
        continuation.finish()
    }
}
