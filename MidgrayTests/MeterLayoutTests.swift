//
//  MeterLayoutTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 26/11/26.
//

import CoreGraphics
import Testing
@testable import Midgray

struct MeterLayoutTests {
    @Test(arguments: [
        (CGSize(width: 402, height: 874), MeterLayout.stacked),
        (CGSize(width: 874, height: 402), MeterLayout.side),
        (CGSize(width: 594, height: 440), MeterLayout.side),
        (CGSize(width: 466, height: 678), MeterLayout.stacked),
        (CGSize(width: 678, height: 466), MeterLayout.side),
        (CGSize(width: 669, height: 951), MeterLayout.stacked),
        (CGSize(width: 951, height: 669), MeterLayout.side),
        (CGSize(width: 500, height: 400), MeterLayout.stacked)
    ])
    func choosesTheLayoutFromTheAvailableSize(size: CGSize, expected: MeterLayout) {
        #expect(MeterLayout(size: size, container: size) == expected)
        #expect(MeterLayout(size: size) == expected)
    }

    @Test
    func detectsThatItOnlyGetsTheBottomHalf() {
        let layout = MeterLayout(size: CGSize(width: 669, height: 450), container: CGSize(width: 669, height: 900))

        #expect(layout == .bottomHalf)
    }

    @Test
    func detectsThatItOnlyGetsTheTrailingHalf() {
        let layout = MeterLayout(size: CGSize(width: 370, height: 669), container: CGSize(width: 867, height: 669))

        #expect(layout == .trailingHalf)
    }
}
