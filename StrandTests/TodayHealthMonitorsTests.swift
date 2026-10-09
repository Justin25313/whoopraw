import XCTest
import SwiftUI
import StrandAnalytics
import StrandDesign
import WhoopStore
@testable import Strand

final class TodayHealthMonitorsTests: XCTestCase {
    private func vital(_ key: String, band: VitalBands.Band = .inRange,
                       basis: VitalBands.Basis = .personal, source: DailyMetricSource = .whoopImport,
                       day: String = "2026-10-08", caveat: String? = nil) -> BodyVitalReading {
        BodyVitalReading(key: key, label: key, unit: "", value: band == .noData ? nil : 50,
                         format: { String($0) }, banding: .init(band: band, basis: basis, nights: 28),
                         metricColor: StrandPalette.accent, day: day, source: source,
                         missingCaption: "", caveat: caveat)
    }

    func testMissingRawAndUnverifiedVitalsCannotCreateHealthyCount() {
        let result = TodayHealthMonitorSummary(readings: [
            vital("spo2raw"), vital("spo2", source: .noopComputed),
            vital("hrv", caveat: "unverified"), vital("rhr", band: .noData)
        ])
        XCTAssertEqual(result.availableCount, 0)
        XCTAssertEqual(result.outlierCount, 0)
        XCTAssertNil(result.latestDay)
    }

    func testCountsPartialCoverageAndOutliersWithoutInventingFiveHealthyValues() {
        let result = TodayHealthMonitorSummary(readings: [
            vital("rhr"), vital("hrv", band: .outOfRange), vital("resp", band: .noData)
        ])
        XCTAssertEqual(result.availableCount, 2)
        XCTAssertEqual(result.outlierCount, 1)
        XCTAssertEqual(result.latestDay, "2026-10-08")
    }

    func testOxygenThresholdDoesNotHidePersonalBaselineButColdStartDoes() {
        let established = TodayHealthMonitorSummary(readings: [
            vital("rhr"), vital("spo2", basis: .population)
        ])
        XCTAssertFalse(established.usesPopulationRange)
        let coldStart = TodayHealthMonitorSummary(readings: [vital("rhr", basis: .population)])
        XCTAssertTrue(coldStart.usesPopulationRange)
    }

    func testMixedNightReadingsAreNotLabelledAsAllFromToday() {
        let result = TodayHealthMonitorSummary(readings: [vital("rhr"), vital("hrv", day: "2026-10-07")])
        XCTAssertNil(result.latestDay)
    }

    private var now: Date { ISO8601DateFormatter().date(from: "2026-10-08T10:00:00Z")! }
    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(secondsFromGMT: 0)!
        return value
    }
    private func point(hoursAgo: Double, score: Double?, masked: Bool = false) -> DaytimeStress.HourPoint {
        .init(hour: 8, startTs: Int(now.addingTimeInterval(-hoursAgo * 3600).timeIntervalSince1970),
              level: score, meanHR: 70, rmssd: 40, maskedForActivity: masked)
    }

    func testIntradayStressUsesNewestValidReadingAndExcludesActivityAndFuture() {
        let result = TodayStressMonitorSummary(points: [
            point(hoursAgo: 3, score: 0.5), point(hoursAgo: 2, score: 1.7),
            point(hoursAgo: 1, score: 2.9, masked: true), point(hoursAgo: -1, score: 3)
        ], dailyScore: 0.2, dailyDay: "2026-10-08", now: now, calendar: calendar)
        XCTAssertEqual(result.score, 1.7)
        XCTAssertNotNil(result.readingDate)
        XCTAssertNil(result.dailyDay)
    }

    func testMissingIntradayDataUsesLabelledFreshDailyFallback() {
        let result = TodayStressMonitorSummary(points: [point(hoursAgo: 1, score: nil)],
                                              dailyScore: 1.4, dailyDay: "2026-10-07",
                                              now: now, calendar: calendar)
        XCTAssertEqual(result.score, 1.4)
        XCTAssertNil(result.readingDate)
        XCTAssertEqual(result.dailyDay, "2026-10-07")
    }

    func testPreviousDayCurveAndStaleDailyScoreCannotMasqueradeAsCurrentStress() {
        let result = TodayStressMonitorSummary(points: [point(hoursAgo: 25, score: 2.8)],
                                              dailyScore: 2.2, dailyDay: "2026-09-01",
                                              now: now, calendar: calendar)
        XCTAssertNil(result.score)
        XCTAssertNil(result.readingDate)
        XCTAssertNil(result.dailyDay)
    }

    func testFutureDailyScoreIsNotDisplayed() {
        let result = TodayStressMonitorSummary(points: [], dailyScore: 1.5, dailyDay: "2026-10-09",
                                              now: now, calendar: calendar)
        XCTAssertNil(result.score)
    }

    @MainActor
    func testHealthActivationPersistsOnceAndRespectsLaterOptOut() throws {
        let name = "TodayHealthMonitorsTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set(false, forKey: "behavior.illnessWatch")
        let first = BehaviorStore(defaults: defaults)
        XCTAssertTrue(first.activateHealthMonitorOnce())
        XCTAssertTrue(first.illnessWatch)
        XCTAssertTrue(defaults.bool(forKey: "behavior.illnessWatch"))
        first.illnessWatch = false
        let restarted = BehaviorStore(defaults: defaults)
        XCTAssertFalse(restarted.activateHealthMonitorOnce())
        XCTAssertFalse(restarted.illnessWatch)
    }
}
