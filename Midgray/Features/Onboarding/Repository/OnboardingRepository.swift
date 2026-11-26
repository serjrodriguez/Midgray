//
//  OnboardingRepository.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation

protocol OnboardingRepository {
    var hasCompleted: Bool { get }

    func markCompleted()
}

struct UserDefaultsOnboardingRepository: OnboardingRepository {
    private static let key = "onboarding.completed"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompleted: Bool {
        defaults.bool(forKey: Self.key)
    }

    func markCompleted() {
        defaults.set(true, forKey: Self.key)
    }
}

final class InMemoryOnboardingRepository: OnboardingRepository {
    private(set) var hasCompleted: Bool

    init(completed: Bool = false) {
        hasCompleted = completed
    }

    func markCompleted() {
        hasCompleted = true
    }
}
