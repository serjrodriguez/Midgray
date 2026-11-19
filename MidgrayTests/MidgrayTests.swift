//
//  MidgrayTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 17/11/26.
//

import Testing
@testable import Midgray

struct MidgrayTests {
    @Test func spacingScaleIsStrictlyAscending() {
        #expect(Spacing.s4 < Spacing.s8)
        #expect(Spacing.s8 < Spacing.s12)
        #expect(Spacing.s12 < Spacing.s16)
        #expect(Spacing.s16 < Spacing.s20)
        #expect(Spacing.s20 < Spacing.s24)
        #expect(Spacing.s24 < Spacing.s28)
        #expect(Spacing.s28 < Spacing.s32)
        #expect(Spacing.s32 < Spacing.s36)
        #expect(Spacing.s36 < Spacing.s40)
    }
    
    @Test func radiusScaleIsStrictlyAscending() {
        #expect(Radius.r14 < Radius.r16)
        #expect(Radius.r16 < Radius.r26)
        #expect(Radius.r26 < Radius.r34)
        #expect(Radius.r34 < Radius.r36)
    }

}
