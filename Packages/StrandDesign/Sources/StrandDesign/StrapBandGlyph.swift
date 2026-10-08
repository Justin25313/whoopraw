import SwiftUI

/// Original screenless wrist-band outline. Normalized paths describe the strap and sensor housing;
/// no vendor artwork is used. The caller owns size, stroke and active-device charge tint.
public struct StrapBandGlyph: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.51, y: h * 0.08))
        path.addCurve(to: CGPoint(x: w * 0.20, y: h * 0.40),
                      control1: CGPoint(x: w * 0.29, y: h * 0.05),
                      control2: CGPoint(x: w * 0.21, y: h * 0.20))
        path.addCurve(to: CGPoint(x: w * 0.39, y: h * 0.92),
                      control1: CGPoint(x: w * 0.17, y: h * 0.65),
                      control2: CGPoint(x: w * 0.20, y: h * 0.90))
        path.addCurve(to: CGPoint(x: w * 0.77, y: h * 0.61),
                      control1: CGPoint(x: w * 0.65, y: h * 0.98),
                      control2: CGPoint(x: w * 0.73, y: h * 0.82))
        path.move(to: CGPoint(x: w * 0.80, y: h * 0.37))
        path.addCurve(to: CGPoint(x: w * 0.51, y: h * 0.08),
                      control1: CGPoint(x: w * 0.82, y: h * 0.15),
                      control2: CGPoint(x: w * 0.70, y: h * 0.07))
        path.addRoundedRect(in: CGRect(x: w * 0.44, y: h * 0.39,
                                      width: w * 0.47, height: h * 0.19),
                            cornerSize: CGSize(width: w * 0.06, height: h * 0.04))
        path.move(to: CGPoint(x: w * 0.23, y: h * 0.68))
        path.addLine(to: CGPoint(x: w * 0.44, y: h * 0.68))
        return path
    }
}
