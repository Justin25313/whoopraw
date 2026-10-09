import XCTest
@testable import Strand

final class Whoop4InitialBatteryReadTests: XCTestCase {
    func testNeitherHandshakeCallbackOrderCanReadBeforeBothAreReady() {
        for handshakeFirst in [false, true] {
            var gate = Whoop4InitialBatteryRead()
            XCTAssertFalse(gate.takeRequest(isWhoop4: true, connected: true, bonded: true,
                handshakeDone: handshakeFirst, replyNotificationsActive: !handshakeFirst,
                backfilling: false))
            XCTAssertFalse(gate.requested)
            XCTAssertTrue(gate.takeRequest(isWhoop4: true, connected: true, bonded: true,
                handshakeDone: true, replyNotificationsActive: true, backfilling: false))
        }
    }

    func testOffloadDefersWithoutConsumingTheRead() {
        var gate = Whoop4InitialBatteryRead()
        for _ in 0..<3 {
            XCTAssertFalse(gate.takeRequest(isWhoop4: true, connected: true, bonded: true,
                handshakeDone: true, replyNotificationsActive: true, backfilling: true))
        }
        XCTAssertFalse(gate.requested)
        XCTAssertTrue(gate.takeRequest(isWhoop4: true, connected: true, bonded: true,
            handshakeDone: true, replyNotificationsActive: true, backfilling: false))
    }

    func testNotifyRefiresAndMultipleOffloadCompletionsDoNotDuplicateTheRead() {
        var gate = Whoop4InitialBatteryRead()
        XCTAssertTrue(gate.takeRequest(isWhoop4: true, connected: true, bonded: true,
            handshakeDone: true, replyNotificationsActive: true, backfilling: false))
        for busy in [false, true, false, false] {
            XCTAssertFalse(gate.takeRequest(isWhoop4: true, connected: true, bonded: true,
                handshakeDone: true, replyNotificationsActive: true, backfilling: busy))
        }
        gate.reset()
        XCTAssertTrue(gate.takeRequest(isWhoop4: true, connected: true, bonded: true,
            handshakeDone: true, replyNotificationsActive: true, backfilling: false))
    }

    func testOtherFamiliesAndIncompleteLinksDoNotConsumeTheRead() {
        for family in [false, true] {
            for connected in [false, true] {
                for bonded in [false, true] where !family || !connected || !bonded {
                    var gate = Whoop4InitialBatteryRead()
                    XCTAssertFalse(gate.takeRequest(isWhoop4: family, connected: connected, bonded: bonded,
                        handshakeDone: true, replyNotificationsActive: true, backfilling: false))
                    XCTAssertFalse(gate.requested)
                }
            }
        }
    }
}
