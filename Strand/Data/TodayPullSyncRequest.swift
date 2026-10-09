import Foundation

/// Resolves a deliberate Today refresh independently of gesture recognition. An unavailable link
/// still gets visible feedback; a connected link finishing its handshake retains the user's request.
enum TodayPullSyncRequest: Equatable {
    case offline
    case waitingForPairing
    case alreadyRunning
    case start

    static func resolve(connected: Bool, bonded: Bool, historyReady: Bool,
                        backfilling: Bool) -> Self {
        guard connected else { return .offline }
        if backfilling { return .alreadyRunning }
        guard bonded, historyReady else { return .waitingForPairing }
        return .start
    }

    /// Uses existing BLE entry points only. Keeping these callbacks separate makes the no-duplicate
    /// and pending-pairing contracts testable without a strap or CoreBluetooth writes.
    func perform(start: () -> Void, queueUntilPaired: () -> Void) {
        switch self {
        case .start: start()
        case .waitingForPairing: queueUntilPaired()
        case .offline, .alreadyRunning: break
        }
    }
}
