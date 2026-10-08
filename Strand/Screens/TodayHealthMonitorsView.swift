import SwiftUI
import StrandDesign
import StrandAnalytics
import Foundation

/// Compact summaries of the existing Health and Stress screens; no new physiological scoring.
struct TodayHealthMonitorsView: View {
    @EnvironmentObject private var repo: Repository
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var hrvOverCountByDay: [String: Double]?
    let stressHours: [DaytimeStress.HourPoint]
    let dailyStress: Double?
    let dailyStressDay: String?

    var body: some View {
        let readings = BodyVitalSigns.readings(sourceRows: repo.vitalMetricRows, temperatureUnit: .celsius,
                                              hrvOverCountByDay: hrvOverCountByDay ?? [:])
        let health = TodayHealthMonitorSummary(readings: hrvOverCountByDay == nil ? [] : readings)
        let stress = TodayStressMonitorSummary(points: stressHours, dailyScore: dailyStress,
                                              dailyDay: dailyStressDay)
        Group {
            if typeSize.isAccessibilitySize {
                VStack(spacing: NoopMetrics.space3) { cards(health: health, stress: stress) }
            } else {
                HStack(alignment: .top, spacing: NoopMetrics.space3) { cards(health: health, stress: stress) }
            }
        }
        .background { HealthMonitorActivation() }
        .task(id: repo.refreshSeq) {
            let flags = await repo.exploreSeries(key: "hrv_rr_overcount", source: "my-whoop", days: 14)
            hrvOverCountByDay = Dictionary(flags.map { ($0.day, $0.value) }, uniquingKeysWith: { _, b in b })
        }
    }

    @ViewBuilder
    private func cards(health: TodayHealthMonitorSummary, stress: TodayStressMonitorSummary) -> some View {
        NavigationLink(value: TabRoute.health) {
            monitor(title: String(localized: "HEALTH\nMONITOR"), color: health.color) {
                Image(systemName: health.availableCount == 0 ? "waveform.path.ecg" :
                      (health.outlierCount > 0 ? "exclamationmark" : "checkmark"))
                    .font(StrandFont.caption)
            } detail: {
                Text(health.status).font(StrandFont.caption).foregroundStyle(health.color)
                Text(health.caption).font(StrandFont.footnote).foregroundStyle(StrandPalette.textSecondary)
            }
        }
        .buttonStyle(LiquidPressStyle())
        .accessibilityIdentifier("today.healthMonitor")

        NavigationLink(value: TabRoute.stress) {
            monitor(title: String(localized: "Stress Monitor"), color: stress.color) {
                Text(stress.score.map { String(format: "%.1f", locale: AppLanguage.activeLocale, $0) } ?? "—")
                    .font(StrandFont.caption)
            } detail: {
                Text(stress.score.map { StressBand(score: $0).title } ?? String(localized: "No data"))
                    .font(StrandFont.caption).foregroundStyle(stress.color)
                Text(stress.caption).font(StrandFont.footnote).foregroundStyle(StrandPalette.textSecondary)
            }
        }
        .buttonStyle(LiquidPressStyle())
        .accessibilityIdentifier("today.stressMonitor")
    }

    private func monitor<Badge: View, Detail: View>(title: String, color: Color,
                                                  @ViewBuilder badge: () -> Badge,
                                                  @ViewBuilder detail: () -> Detail) -> some View {
        VStack(alignment: .leading, spacing: NoopMetrics.space3) {
            HStack(alignment: .top, spacing: NoopMetrics.space2) {
                Text(title.uppercased()).font(StrandFont.overline)
                    .lineLimit(2).minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity, minHeight: NoopMetrics.space8, alignment: .topLeading)
                Image(systemName: "chevron.right").font(StrandFont.caption)
                    .foregroundStyle(StrandPalette.textSecondary)
            }
            HStack(alignment: .top, spacing: NoopMetrics.space2) {
                badge().foregroundStyle(color)
                    .frame(width: NoopMetrics.space6, height: NoopMetrics.space6)
                    .background(color.opacity(0.14), in: RoundedRectangle(cornerRadius: NoopMetrics.space1))
                VStack(alignment: .leading, spacing: NoopMetrics.space1) { detail() }
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .foregroundStyle(StrandPalette.textPrimary)
        .padding(NoopMetrics.space3)
        .frame(maxWidth: .infinity, minHeight: NoopMetrics.todayMonitorMinHeight, alignment: .topLeading)
        .background(NoopPanelSurface(cornerRadius: NoopMetrics.todayCardRadius))
    }
}

/// Uncalibrated raw oxygen, experimental candidates and unverified HRV never count as healthy values.
struct TodayHealthMonitorSummary {
    let availableCount: Int
    let outlierCount: Int
    let usesPopulationRange: Bool
    let latestDay: String?

    init(readings: [BodyVitalReading]) {
        let keys: Set<String> = ["rhr", "hrv", "resp", "skin", "spo2"]
        let available = readings.filter {
            keys.contains($0.key) && $0.value != nil && $0.banding.band != .noData && $0.caveat == nil
                && !($0.key == "spo2" && $0.source == .noopComputed)
        }
        availableCount = available.count
        outlierCount = available.filter { $0.banding.band == .outOfRange }.count
        // Calibrated oxygen always has an absolute threshold rather than a personal HRV-style baseline.
        usesPopulationRange = available.contains { $0.key != "spo2" && $0.banding.basis == .population }
        let days = Set(available.compactMap(\.day))
        latestDay = days.count == 1 ? days.first : nil
    }

    var color: Color {
        availableCount == 0 ? StrandPalette.textTertiary :
            (outlierCount > 0 ? StrandPalette.statusWarning : StrandPalette.statusPositive)
    }
    var status: String {
        if availableCount == 0 { return String(localized: "No data") }
        if outlierCount > 0 { return String(localized: "Check vitals") }
        return usesPopulationRange ? String(localized: "Typical range") : String(localized: "Within range")
    }
    var caption: String {
        guard availableCount > 0 else { return String(localized: "Waiting for readings") }
        let count = String(localized: "\(availableCount)/5 metrics available")
        return count + " · " + (latestDay.map(BodyVitalReading.dayLabel) ?? String(localized: "Recent readings"))
    }
}

/// A timestamped intraday reading takes priority; daily fallback is explicitly labelled and freshness-bound.
struct TodayStressMonitorSummary {
    let score: Double?
    let readingDate: Date?
    let dailyDay: String?

    init(points: [DaytimeStress.HourPoint], dailyScore: Double?, dailyDay: String?, now: Date = Date(),
         calendar: Calendar = .current) {
        let midnight = calendar.startOfDay(for: now).timeIntervalSince1970
        if let point = points.filter({
            guard let value = $0.level else { return false }
            return value.isFinite && (0...3).contains(value) && !$0.maskedForActivity
                && Double($0.startTs) >= midnight && Double($0.startTs) <= now.timeIntervalSince1970
        }).max(by: { $0.startTs < $1.startTs }) {
            score = point.level
            readingDate = Date(timeIntervalSince1970: TimeInterval(point.startTs))
            self.dailyDay = nil
        } else {
            let today = BodyVitalSigns.logicalDayKey(now)
            let fresh: Double? = dailyDay.flatMap { day in
                guard day <= today else { return nil }
                return dailyScore.flatMap { value in
                    value.isFinite && (0...3).contains(value)
                        ? Baselines.freshestCarried([(day: day, value: value)], todayKey: today)?.value : nil
                }
            }
            score = fresh
            readingDate = nil
            self.dailyDay = fresh != nil ? dailyDay : nil
        }
    }

    var color: Color { score.map(StressRamp.color) ?? StrandPalette.textTertiary }
    var caption: String {
        if let readingDate {
            return DateFormatter.localizedString(from: readingDate, dateStyle: .none, timeStyle: .short)
        }
        if let dailyDay {
            return String(localized: "Daily value") + " · " + BodyVitalReading.dayLabel(dailyDay)
        }
        return String(localized: "Waiting for readings")
    }
}

/// Isolates AppModel's one-Hz observation from the two summary cards.
private struct HealthMonitorActivation: View {
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var behavior: BehaviorStore

    var body: some View {
        Color.clear.task {
            if behavior.activateHealthMonitorOnce() {
                model.reevaluateIllness()
                IllnessNotifier.requestAuthorization()
            }
        }
    }
}
