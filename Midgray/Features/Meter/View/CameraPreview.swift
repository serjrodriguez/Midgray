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
    }
}

final class PreviewView: UIView {
    var onTap: (CGPoint, CGPoint) -> Void = { _, _ in }

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

    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard bounds.width > 0, bounds.height > 0 else { return }

        let location = recognizer.location(in: self)
        let devicePoint = previewLayer.captureDevicePointConverted(fromLayerPoint: location)
        let viewPoint = CGPoint(x: location.x / bounds.width, y: location.y / bounds.height)
        onTap(viewPoint, devicePoint)
    }
}
