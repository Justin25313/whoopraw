/// Retains one battery read until this connection's reply channel is ready and history is idle.
/// The discovery-time bond write precedes notify confirmation, so it cannot supply this guarantee.
struct Whoop4InitialBatteryRead {
    private(set) var requested = false

    mutating func takeRequest(isWhoop4: Bool, connected: Bool, bonded: Bool,
                              handshakeDone: Bool, replyNotificationsActive: Bool,
                              backfilling: Bool) -> Bool {
        guard !requested, isWhoop4, connected, bonded, handshakeDone,
              replyNotificationsActive, !backfilling else { return false }
        requested = true
        return true
    }

    mutating func reset() { requested = false }
}
