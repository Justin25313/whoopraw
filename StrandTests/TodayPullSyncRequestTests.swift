import XCTest
@testable import Strand

final class TodayPullSyncRequestTests: XCTestCase {
    func testOfflinePullNeverWritesOrQueuesAgainstAnAbsentStrap() {
        for bonded in [false, true] {
            for ready in [false, true] {
                for backfilling in [false, true] {
                    let action = TodayPullSyncRequest.resolve(connected: false, bonded: bonded,
                                                             historyReady: ready, backfilling: backfilling)
                    XCTAssertEqual(action, .offline)
                    action.perform(start: { XCTFail("Cannot start offline") },
                                   queueUntilPaired: { XCTFail("Cannot queue for an absent strap") })
                }
            }
        }
    }

    func testPullDuringOffloadReusesItEvenIfReadinessChanges() {
        for bonded in [false, true] {
            for ready in [false, true] {
                let action = TodayPullSyncRequest.resolve(connected: true, bonded: bonded,
                                                         historyReady: ready, backfilling: true)
                XCTAssertEqual(action, .alreadyRunning)
                action.perform(start: { XCTFail("Must not duplicate an offload") },
                               queueUntilPaired: { XCTFail("Must not queue a duplicate") })
            }
        }
    }

    func testPullBeforeHandshakeIsRetainedInsteadOfSilentlyLost() {
        for (bonded, ready) in [(false, false), (false, true), (true, false)] {
            let action = TodayPullSyncRequest.resolve(connected: true, bonded: bonded,
                                                     historyReady: ready, backfilling: false)
            XCTAssertEqual(action, .waitingForPairing)
            var queued = 0
            action.perform(start: { XCTFail("Handshake is not ready") },
                           queueUntilPaired: { queued += 1 })
            XCTAssertEqual(queued, 1)
        }
    }

    func testReadyPullCallsTheManualSyncEntryPointOnce() {
        let action = TodayPullSyncRequest.resolve(connected: true, bonded: true,
                                                 historyReady: true, backfilling: false)
        XCTAssertEqual(action, .start)
        var starts = 0
        action.perform(start: { starts += 1 }, queueUntilPaired: { XCTFail("Already ready") })
        XCTAssertEqual(starts, 1)
    }
}
