//
//  LightSensing.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 23/11/26.
//

import Foundation

protocol LightSensing: Sendable {
    func readings() -> AsyncStream<CameraReading>
}
