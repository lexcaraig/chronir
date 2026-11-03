import Testing
import Foundation
@testable import chronir

struct PlusFeatureTests {
    @Test func highlightMovesFeatureToTopWithoutDuplicates() {
        let ordered = PlusFeature.ordered(highlighting: .sounds)
        #expect(ordered.first == .sounds)
        #expect(ordered.count == PlusFeature.allCases.count)
        #expect(Set(ordered).count == PlusFeature.allCases.count)
    }

    @Test func noHighlightKeepsCanonicalOrder() {
        #expect(PlusFeature.ordered(highlighting: nil) == PlusFeature.allCases)
    }

    @Test func freeAlarmValueMatchesTierLimit() {
        #expect(PlusFeature.unlimitedAlarms.freeValue == "3")
    }

    @Test func soundCountsComeFromSoundService() {
        #expect(PlusFeature.sounds.freeValue == "\(AlarmSoundService.freeSounds.count)")
        #expect(PlusFeature.sounds.plusValue == "\(AlarmSoundService.allSounds.count)")
    }
}

struct PlanPricingTests {
    @Test func annualSavingsVsMonthly() {
        // $1.99 x 12 = $23.88; $19.99 saves 16.29% -> 16
        #expect(PlanPricing.savingsPercent(monthly: Decimal(string: "1.99")!, annual: Decimal(string: "19.99")!) == 16)
    }

    @Test func noSavingsWhenAnnualIsNotCheaper() {
        #expect(PlanPricing.savingsPercent(monthly: 1, annual: 12) == nil)
        #expect(PlanPricing.savingsPercent(monthly: 1, annual: 15) == nil)
    }

    @Test func zeroMonthlyPriceHasNoSavings() {
        #expect(PlanPricing.savingsPercent(monthly: 0, annual: 10) == nil)
    }

    @Test func monthlyEquivalentDividesByTwelve() {
        #expect(PlanPricing.monthlyEquivalent(annual: 24) == 2)
    }
}
