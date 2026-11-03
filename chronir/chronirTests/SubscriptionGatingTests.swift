import Testing
import Foundation
@testable import chronir

// MARK: - SubscriptionTier Properties

struct SubscriptionTierTests {

    // MARK: Alarm Limits

    @Test func freeAlarmLimit() {
        #expect(SubscriptionTier.free.alarmLimit == 3)
    }

    @Test func plusAlarmLimitNil() {
        #expect(SubscriptionTier.plus.alarmLimit == nil)
    }

    @Test func premiumAlarmLimitNil() {
        #expect(SubscriptionTier.premium.alarmLimit == nil)
    }

    @Test func familyAlarmLimitNil() {
        #expect(SubscriptionTier.family.alarmLimit == nil)
    }

    // MARK: isFreeTier

    @Test func freeIsFreeTier() {
        #expect(SubscriptionTier.free.isFreeTier == true)
    }

    @Test func paidTiersNotFree() {
        #expect(SubscriptionTier.plus.isFreeTier == false)
        #expect(SubscriptionTier.premium.isFreeTier == false)
        #expect(SubscriptionTier.family.isFreeTier == false)
    }

    // MARK: Rank Ordering

    @Test func tierRankOrdering() {
        #expect(SubscriptionTier.free.rank < SubscriptionTier.plus.rank)
        #expect(SubscriptionTier.plus.rank < SubscriptionTier.premium.rank)
        #expect(SubscriptionTier.premium.rank < SubscriptionTier.family.rank)
    }

    // MARK: Display Names

    @Test func tierDisplayNames() {
        #expect(SubscriptionTier.free.displayName == "Free")
        #expect(SubscriptionTier.plus.displayName == "Plus")
        #expect(SubscriptionTier.premium.displayName == "Premium")
        #expect(SubscriptionTier.family.displayName == "Family")
    }
}

// MARK: - Alarm Limit Enforcement Logic

struct AlarmLimitEnforcementTests {

    /// Replicates PaywallViewModel.canCreateAlarm logic
    private func canCreateAlarm(tier: SubscriptionTier, currentCount: Int) -> Bool {
        guard let limit = tier.alarmLimit else { return true }
        return currentCount < limit
    }

    @Test func freeCanCreate2of3() {
        #expect(canCreateAlarm(tier: .free, currentCount: 2) == true)
    }

    @Test func freeBlocked3of3() {
        #expect(canCreateAlarm(tier: .free, currentCount: 3) == false)
    }

    @Test func freeBlocked5of3() {
        #expect(canCreateAlarm(tier: .free, currentCount: 5) == false)
    }

    @Test func plusUnlimited() {
        #expect(canCreateAlarm(tier: .plus, currentCount: 100) == true)
    }

    private func alarm(_ title: String, ageDays: Double) -> Alarm {
        let alarm = Alarm(title: title)
        alarm.createdAt = Date().addingTimeInterval(-ageDays * 86_400)
        return alarm
    }

    @Test func downgradeFreeTierDisablesNewestExcess() {
        let alarms = (1...5).map { alarm("A\($0)", ageDays: Double(10 - $0)) } // A1 oldest
        let limit = SubscriptionTier.free.alarmLimit ?? 3
        let toDisable = AlarmLimitPolicy.alarmsToDisable(enabled: alarms, limit: limit)
        #expect(toDisable.map(\.title) == ["A4", "A5"])
        #expect(AlarmLimitPolicy.alarmsToDisable(enabled: Array(alarms.prefix(3)), limit: limit).isEmpty)
    }

    @Test func upgradeRestoresOnlyLimitDisabledAlarms() {
        let pausedByLimit = alarm("Limit", ageDays: 1)
        let pausedByUser = alarm("User", ageDays: 2)
        let restored = AlarmLimitPolicy.alarmsToRestore(
            disabled: [pausedByLimit, pausedByUser],
            limitDisabled: [pausedByLimit.id]
        )
        #expect(restored.map(\.id) == [pausedByLimit.id])
    }

    @Test func limitDisabledIDsRoundTrip() throws {
        let defaults = try #require(UserDefaults(suiteName: "AlarmLimitPolicyTests"))
        defaults.removePersistentDomain(forName: "AlarmLimitPolicyTests")
        let ids: Set<UUID> = [UUID(), UUID()]
        AlarmLimitPolicy.save(ids, to: defaults)
        #expect(AlarmLimitPolicy.load(from: defaults) == ids)
        AlarmLimitPolicy.save([], to: defaults)
        #expect(AlarmLimitPolicy.load(from: defaults).isEmpty)
    }
}

// MARK: - Product ID → Tier Mapping

struct ProductIDMappingTests {

    @Test func plusMonthlyMapsToPlus() {
        #expect(SubscriptionService.tierForProductID("com.chronir.plus.monthly") == .plus)
    }

    @Test func plusAnnualMapsToPlus() {
        #expect(SubscriptionService.tierForProductID("com.chronir.plus.annual") == .plus)
    }

    @Test func plusLifetimeMapsToPlus() {
        #expect(SubscriptionService.tierForProductID("com.chronir.plus.lifetime") == .plus)
    }

    @Test func premiumMapsToCorrectTier() {
        #expect(SubscriptionService.tierForProductID("com.chronir.premium.annual") == .premium)
    }

    @Test func unknownProductMapsFree() {
        #expect(SubscriptionService.tierForProductID("com.unknown.product") == .free)
    }
}

// MARK: - PreAlarmOffset Gating

struct PreAlarmOffsetGatingTests {

    @Test func oneDayFreeForAllTiers() {
        #expect(PreAlarmOffset.oneDay.requiresPlus == false)
    }

    @Test func plusOnlyOffsets() {
        #expect(PreAlarmOffset.oneHour.requiresPlus == true)
        #expect(PreAlarmOffset.threeDays.requiresPlus == true)
        #expect(PreAlarmOffset.sevenDays.requiresPlus == true)
    }

    @Test func allOffsetsAccountedFor() {
        #expect(PreAlarmOffset.allCases.count == 4)
    }
}

// MARK: - Sound Gating

struct SoundGatingTests {

    @Test func freeSoundsCount() {
        #expect(AlarmSoundService.freeSounds.count == 2)
    }

    @Test func allSoundsCount() {
        #expect(AlarmSoundService.allSounds.count == 6)
    }

    @Test func freeSoundsDontRequirePlus() {
        for sound in AlarmSoundService.freeSounds {
            #expect(sound.requiresPlus == false, "Free sound '\(sound.name)' should not require Plus")
        }
    }
}

// MARK: - UserProfile & Codable

struct UserProfileGatingTests {

    @Test func defaultTierIsFree() {
        let profile = UserProfile(id: "test", displayName: "Test", email: "test@example.com")
        #expect(profile.tier == .free)
    }

    @Test func tierCodableRoundTrip() throws {
        let original = UserProfile(id: "u1", displayName: "Lex", email: "lex@example.com", tier: .plus)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(UserProfile.self, from: data)
        #expect(decoded.tier == .plus)
        #expect(decoded.id == original.id)
        #expect(decoded.displayName == original.displayName)
    }

    @Test func subscriptionTierCodableRoundTrip() throws {
        for tier in SubscriptionTier.allCases {
            let data = try JSONEncoder().encode(tier)
            let decoded = try JSONDecoder().decode(SubscriptionTier.self, from: data)
            #expect(decoded == tier, "Round-trip failed for \(tier)")
        }
    }
}
