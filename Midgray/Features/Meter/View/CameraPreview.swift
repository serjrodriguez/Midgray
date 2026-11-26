//
//  CameraPreview.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    var configuration = ""
    var onTap: (_ viewPoint: CGPoint, _ devicePoint: CGPoint) -> Void = { _, _ in }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        view.onTap = onTap
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.onTap = onTap
        uiView.updateRotation()
    }
}

final class PreviewView: UIView {
    var onTap: (CGPoint, CGPoint) -> Void = { _, _ in }

    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var rotationObservation: NSKeyValueObservation?

    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateRotation()
    }

    func updateRotation() {
        guard let device = (previewLayer.session?.inputs.first as? AVCaptureDeviceInput)?.device else { return }

        if rotationCoordinator?.device != device {
            let coordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: previewLayer)
            rotationCoordinator = coordinator
            rotationObservation = coordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: [.new]) { [weak self] _, change in
                guard let angle = change.newValue else { return }
                Task { @MainActor in self?.applyRotation(angle) }
            }
        }

        if let angle = rotationCoordinator?.videoRotationAngleForHorizonLevelPreview {
            applyRotation(angle)
        }
    }

    private func applyRotation(_ angle: CGFloat) {
        guard let connection = previewLayer.connection,
              connection.isVideoRotationAngleSupported(angle),
              connection.videoRotationAngle != angle else { return }
        connection.videoRotationAngle = angle
    }

    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard bounds.width > 0, bounds.height > 0 else { return }

        let location = recognizer.location(in: self)
        let devicePoint = previewLayer.captureDevicePointConverted(fromLayerPoint: location)
        let viewPoint = CGPoint(x: location.x / bounds.width, y: location.y / bounds.height)
        onTap(viewPoint, devicePoint)
    }
}
