//
//  Colors.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

extension Color {
    static let meterAccent = Color.blue
    static let meterInputFill = Color.white.opacity(0.08)
    static let meterInputBorder = Color.white.opacity(0.55)
    static let meterResultFill = Color.white.opacity(0.92)
    static let meterResultText = Color(red: 18 / 255, green: 18 / 255, blue: 20 / 255)
    static let meterResultSecondaryText = Color.meterResultText.opacity(0.65)
    static let meterWheelFill = Color(red: 0.14, green: 0.14, blue: 0.155)
    static let meterWheelBand = Color.white.opacity(0.14)
}
