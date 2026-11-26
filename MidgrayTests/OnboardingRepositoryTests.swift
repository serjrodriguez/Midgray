//
//  OnboardingRepositoryTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Testing
import Foundation
@testable import Midgray

@MainActor
struct OnboardingRepositoryTests {
    func makeDefaults() throws -> (UserDefaults, String) {
        let name = "OnboardingRepositoryTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: name))
        return (defaults, name)
    }

    @Test
    func isNotCompletedByDefault() throws {
        let (defaults, name) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: name) }

        #expect(!UserDefaultsOnboardingRepository(defaults: defaults).hasCompleted)
    }

    @Test
    func rememberingCompletionSurvivesANewInstance() throws {
        let (defaults, name) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: name) }

        UserDefaultsOnboardingRepository(defaults: defaults).markCompleted()

        #expect(UserDefaultsOnboardingRepository(defaults: defaults).hasCompleted)
    }

    @Test
    func inMemoryRepositoryTracksCompletion() {
        let repository = InMemoryOnboardingRepository()
        #expect(!repository.hasCompleted)

        repository.markCompleted()

        #expect(repository.hasCompleted)
    }
}
