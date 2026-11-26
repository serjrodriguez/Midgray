//
//  MeterLayout.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 26/11/26.
//

import CoreGraphics

nonisolated enum MeterLayout: Equatable, Sendable {
    case stacked
    case side
    case bottomHalf
    case trailingHalf

    static let minimumSideWidth: CGFloat = 560
    static let minimumShare: CGFloat = 0.75

    init(size: CGSize, container: CGSize? = nil) {
        if let container, size.height < container.height * Self.minimumShare {
            self = .bottomHalf
        } else if let container, size.width < container.width * Self.minimumShare {
            self = .trailingHalf
        } else if size.width > size.height, size.width >= Self.minimumSideWidth {
            self = .side
        } else {
            self = .stacked
        }
    }
}
