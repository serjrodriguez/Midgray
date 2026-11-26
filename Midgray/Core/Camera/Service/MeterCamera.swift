//
//  MeterCamera.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 23/11/26.
//

import Foundation
import AVFoundation

actor MeterCamera: LightSensing {
    nonisolated(unsafe) let session = AVCaptureSession()
    nonisolated let lenses: [CameraLens]

    private let queue = DispatchSerialQueue(label: "com.sergiorodriguez.Midgray.camera")
    private var device: AVCaptureDevice?
    private var meteringPoint: CGPoint?
    private var activeRuns = 0

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        queue.asUnownedSerialExecutor()
    }

    init() {
        lenses = MeterCamera.discoverLenses()
    }

    nonisolated func readings() -> AsyncThrowingStream<CameraReading, any Error> {
        AsyncThrowingStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let task = Task { await self.run(continuation) }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func setMeteringPoint(_ point: CGPoint?) {
        meteringPoint = point

        guard let device else { return }
        prepareExposure(of: device)
    }

    func selectLens(_ lens: CameraLens) {
        guard let newDevice = AVCaptureDevice(uniqueID: lens.id),
              newDevice != device else { return }

        meteringPoint = nil

        guard !session.inputs.isEmpty else {
            device = newDevice
            return
        }

        guard let newInput = try? AVCaptureDeviceInput(device: newDevice) else { return }

        let previousInputs = session.inputs
        session.beginConfiguration()
        for input in previousInputs { session.removeInput(input) }

        guard session.canAddInput(newInput) else {
            for input in previousInputs where session.canAddInput(input) { session.addInput(input) }
            session.commitConfiguration()
            return
        }

        session.addInput(newInput)
        session.commitConfiguration()

        prepareExposure(of: newDevice)
        device = newDevice
    }

    private func run(_ continuation: AsyncThrowingStream<CameraReading, any Error>.Continuation) async {
        guard configureSession() else {
            continuation.finish(throwing: LightSensingError.cameraUnavailable)
            return
        }

        activeRuns += 1
        if !session.isRunning {
            session.startRunning()
        }

        while !Task.isCancelled {
            if let device {
                continuation.yield(CameraReading(
                    aperture: Double(device.lensAperture),
                    exposureTime: CMTimeGetSeconds(device.exposureDuration),
                    iso: Double(device.iso),
                    exposureTargetOffset: Double(device.exposureTargetOffset)
                ))
            }
            try? await Task.sleep(for: .milliseconds(100))
        }

        activeRuns -= 1
        if activeRuns == 0 {
            session.stopRunning()
        }
        continuation.finish()
    }

    private func configureSession() -> Bool {
        guard session.inputs.isEmpty else { return true }

        guard let camera = device ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else { return false }

        session.automaticallyConfiguresApplicationAudioSession = false
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        guard session.canAddOutput(output) else {
            session.removeInput(input)
            return false
        }
        session.addOutput(output)

        prepareExposure(of: camera)
        device = camera
        return true
    }

    private func prepareExposure(of camera: AVCaptureDevice) {
        guard (try? camera.lockForConfiguration()) != nil else { return }

        if camera.isExposurePointOfInterestSupported {
            camera.exposurePointOfInterest = meteringPoint ?? CGPoint(x: 0.5, y: 0.5)
        }
        if camera.isExposureModeSupported(.continuousAutoExposure) {
            camera.exposureMode = .continuousAutoExposure
        }
        if camera.isFocusModeSupported(.continuousAutoFocus) {
            camera.focusMode = .continuousAutoFocus
        }
        if camera.isAutoFocusRangeRestrictionSupported {
            camera.autoFocusRangeRestriction = .none
        }
        camera.unlockForConfiguration()
    }

    private nonisolated static func discoverLenses() -> [CameraLens] {
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInUltraWideCamera, .builtInWideAngleCamera, .builtInTelephotoCamera],
            mediaType: .video,
            position: .back
        )
        let devices = discovery.devices
        guard let wide = devices.first(where: { $0.deviceType == .builtInWideAngleCamera }) else { return [] }

        let referenceFieldOfView = Double(wide.activeFormat.videoFieldOfView)

        return devices.compactMap { camera in
            let kind: CameraLens.Kind
            switch camera.deviceType {
            case .builtInUltraWideCamera: kind = .ultraWide
            case .builtInTelephotoCamera: kind = .telephoto
            default: kind = .wide
            }

            let factor = kind == .wide
                ? 1
                : CameraLens.zoomFactor(fieldOfView: Double(camera.activeFormat.videoFieldOfView), referenceFieldOfView: referenceFieldOfView)

            guard let factor else { return nil }
            return CameraLens(id: camera.uniqueID, kind: kind, zoomFactor: factor)
        }
        .sorted { $0.zoomFactor < $1.zoomFactor }
    }
}
