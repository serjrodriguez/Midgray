//
//  FakeLightSensorTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 23/11/26.
//

import Testing
@testable import Midgray

struct FakeLightSensorTests {
    @Test
    func emitsTheScriptedReadingsInOrderAndFinishes() async {
        let first = CameraReading(aperture: 1.78, exposureTime: 0.01, iso: 50, exposureTargetOffset: 0)
        let second = CameraReading(aperture: 1.78, exposureTime: 0.02, iso: 100, exposureTargetOffset: 0.3)
        let sensor: any LightSensing = FakeLightSensor(scriptedReadings: [first, second])

        var received: [CameraReading] = []
        for await reading in sensor.readings() { received.append(reading) }

        #expect(received == [first, second])
    }
}
