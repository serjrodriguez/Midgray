//
//  MeterState.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation

nonisolated struct MeterReadout: Equatable {
    let ev: Double
    let compensatedEV: Double
    let suggestion: ExposureSuggestion?
    let equivalents: [ExposureSuggestion]
}

nonisolated enum MeterState: Equatable {
    case idle
    case measuring(MeterReadout)
    case outOfRange(MeterReadout)
}
