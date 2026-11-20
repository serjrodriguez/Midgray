//
//  ExposureSuggestion.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 20/11/26.
//

import Foundation

nonisolated enum ExposurePriority {
    case aperture(Double)
    case shutter(Double)
}

nonisolated struct ExposureSuggestion: Equatable {
    let aperture: Double
    let exposureTime: Double
    let iso: Double
    let evError: Double

    static func suggestion(ev100: Double, baseISO: Double, priority: ExposurePriority) -> ExposureSuggestion? {
        guard let roundedISO = ExposureScale.nearest(to: baseISO, in: ExposureScale.isoValues) else { return nil }

        switch priority {
        case .aperture(let aperture):
            guard let roundedAperture = ExposureScale.nearest(to: aperture, in: ExposureScale.apertures),
                  let exposureTime = ExposureMath.exposureTime(ev100: ev100, aperture: roundedAperture, iso: roundedISO),
                  let roundedTime = ExposureScale.nearest(to: exposureTime, in: ExposureScale.shutterSpeeds)
            else { return nil }

            return make(ev100: ev100, aperture: roundedAperture, exposureTime: roundedTime, iso: roundedISO)

        case .shutter(let shutterSpeed):
            guard let roundedTime = ExposureScale.nearest(to: shutterSpeed, in: ExposureScale.shutterSpeeds),
                  let aperture = ExposureMath.aperture(ev100: ev100, exposureTime: roundedTime, iso: roundedISO),
                  let roundedAperture = ExposureScale.nearest(to: aperture, in: ExposureScale.apertures)
            else { return nil }

            return make(ev100: ev100, aperture: roundedAperture, exposureTime: roundedTime, iso: roundedISO)
        }
    }

    static func equivalents(ev100: Double, iso: Double, maximumEVError: Double = 0.5) -> [ExposureSuggestion] {
        ExposureScale.apertures.compactMap { aperture in
            suggestion(ev100: ev100, baseISO: iso, priority: .aperture(aperture))
        }
        .filter { abs($0.evError) <= maximumEVError }
    }

    private static func make(ev100: Double, aperture: Double, exposureTime: Double, iso: Double) -> ExposureSuggestion? {
        guard let achievedEV = ExposureMath.ev100(aperture: aperture, exposureTime: exposureTime, iso: iso) else { return nil }

        return ExposureSuggestion(aperture: aperture, exposureTime: exposureTime, iso: iso, evError: ev100 - achievedEV)
    }
}
