//
//  ExposureSuggestion.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 20/11/26.
//

import Foundation

nonisolated enum ExposurePriority: Equatable {
    case aperture(Double)
    case shutter(Double)
    case iso(aperture: Double, shutter: Double)
}

nonisolated struct ExposureSuggestion: Equatable {
    let aperture: Double
    let exposureTime: Double
    let iso: Double
    let evError: Double

    static let equivalentEVErrors: Range<Double> = (-1.0 / 6 - 1e-6)..<(1.0 / 6 - 1e-6)

    static func suggestion(ev100: Double, baseISO: Double, priority: ExposurePriority) -> ExposureSuggestion? {
        switch priority {
        case .aperture(let aperture):
            guard let iso = ExposureScale.stop(labelled: baseISO, in: ExposureScale.isoStops),
                  let aperture = ExposureScale.stop(labelled: aperture, in: ExposureScale.apertureStops),
                  let time = ExposureMath.exposureTime(ev100: ev100, aperture: aperture.exact, iso: iso.exact),
                  let shutter = ExposureScale.stop(closestTo: time, in: ExposureScale.shutterStops)
            else { return nil }

            return make(ev100: ev100, aperture: aperture, shutter: shutter, iso: iso)

        case .shutter(let shutterSpeed):
            guard let iso = ExposureScale.stop(labelled: baseISO, in: ExposureScale.isoStops),
                  let shutter = ExposureScale.stop(labelled: shutterSpeed, in: ExposureScale.shutterStops),
                  let fNumber = ExposureMath.aperture(ev100: ev100, exposureTime: shutter.exact, iso: iso.exact),
                  let aperture = ExposureScale.stop(closestTo: fNumber, in: ExposureScale.apertureStops)
            else { return nil }

            return make(ev100: ev100, aperture: aperture, shutter: shutter, iso: iso)

        case .iso(let aperture, let shutterSpeed):
            guard let aperture = ExposureScale.stop(labelled: aperture, in: ExposureScale.apertureStops),
                  let shutter = ExposureScale.stop(labelled: shutterSpeed, in: ExposureScale.shutterStops),
                  let sensitivity = ExposureMath.iso(ev100: ev100, aperture: aperture.exact, exposureTime: shutter.exact),
                  let iso = ExposureScale.stop(closestTo: sensitivity, in: ExposureScale.isoStops)
            else { return nil }

            return make(ev100: ev100, aperture: aperture, shutter: shutter, iso: iso)
        }
    }

    static func equivalents(ev100: Double, iso: Double) -> [ExposureSuggestion] {
        ExposureScale.apertures.compactMap { aperture in
            suggestion(ev100: ev100, baseISO: iso, priority: .aperture(aperture))
        }
        .filter { equivalentEVErrors.contains($0.evError) }
    }

    private static func make(ev100: Double, aperture: ExposureStop, shutter: ExposureStop, iso: ExposureStop) -> ExposureSuggestion? {
        guard let achievedEV = ExposureMath.ev100(aperture: aperture.exact, exposureTime: shutter.exact, iso: iso.exact) else { return nil }

        return ExposureSuggestion(aperture: aperture.nominal, exposureTime: shutter.nominal, iso: iso.nominal, evError: ev100 - achievedEV)
    }
}
