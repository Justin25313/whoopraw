import Foundation

/// Local Apple-client preference for comparing the two supplied battery illustrations.
enum BandGraphicStyle: String, CaseIterable, Identifiable, Hashable {
    case realistic
    case outline

    var id: String { rawValue }
    static let storageKey = "whoopraw.bandGraphicStyle"

    var label: String {
        switch self {
        case .realistic: return String(localized: "Realistic")
        case .outline: return String(localized: "Outline")
        }
    }

    static func resolve(_ raw: String) -> Self { Self(rawValue: raw) ?? .realistic }
}
