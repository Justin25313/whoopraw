import SwiftUI

/// Original three-quarter view of a closed fabric wrist band with a broad, screenless sensor clasp.
/// Normalized paths describe the object rather than vendor artwork. The caller owns size and tint.
public struct StrapBandGlyph: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        // A wide fabric loop seen from the side. Its open centre stays legible at header size.
        path.move(to: CGPoint(x: w * 0.34, y: h * 0.12))
        path.addCurve(to: CGPoint(x: w * 0.94, y: h * 0.41),
                      control1: CGPoint(x: w * 0.76, y: h * -0.06),
                      control2: CGPoint(x: w * 0.97, y: h * 0.05))
        path.addCurve(to: CGPoint(x: w * 0.58, y: h * 0.95),
                      control1: CGPoint(x: w * 0.96, y: h * 0.74),
                      control2: CGPoint(x: w * 0.86, y: h * 0.97))
        path.addCurve(to: CGPoint(x: w * 0.13, y: h * 0.72),
                      control1: CGPoint(x: w * 0.27, y: h * 0.94),
                      control2: CGPoint(x: w * 0.16, y: h * 0.87))
        path.move(to: CGPoint(x: w * 0.60, y: h * 0.17))
        path.addCurve(to: CGPoint(x: w * 0.80, y: h * 0.43),
                      control1: CGPoint(x: w * 0.73, y: h * 0.17),
                      control2: CGPoint(x: w * 0.82, y: h * 0.24))
        path.addCurve(to: CGPoint(x: w * 0.57, y: h * 0.83),
                      control1: CGPoint(x: w * 0.81, y: h * 0.67),
                      control2: CGPoint(x: w * 0.71, y: h * 0.83))
        path.addCurve(to: CGPoint(x: w * 0.38, y: h * 0.72),
                      control1: CGPoint(x: w * 0.44, y: h * 0.83),
                      control2: CGPoint(x: w * 0.37, y: h * 0.79))
        // The long, slanted front clasp is screenless: one cross-seam, no watch-face inset.
        path.move(to: CGPoint(x: w * 0.33, y: h * 0.16))
        path.addQuadCurve(to: CGPoint(x: w * 0.56, y: h * 0.14),
                         control: CGPoint(x: w * 0.47, y: h * 0.10))
        path.addQuadCurve(to: CGPoint(x: w * 0.61, y: h * 0.23),
                         control: CGPoint(x: w * 0.63, y: h * 0.15))
        path.addLine(to: CGPoint(x: w * 0.38, y: h * 0.67))
        path.addQuadCurve(to: CGPoint(x: w * 0.28, y: h * 0.73),
                         control: CGPoint(x: w * 0.35, y: h * 0.74))
        path.addLine(to: CGPoint(x: w * 0.11, y: h * 0.72))
        path.addQuadCurve(to: CGPoint(x: w * 0.07, y: h * 0.63),
                         control: CGPoint(x: w * 0.03, y: h * 0.72))
        path.addLine(to: CGPoint(x: w * 0.26, y: h * 0.23))
        path.addQuadCurve(to: CGPoint(x: w * 0.33, y: h * 0.16),
                         control: CGPoint(x: w * 0.28, y: h * 0.18))
        path.closeSubpath()
        path.move(to: CGPoint(x: w * 0.09, y: h * 0.61))
        path.addLine(to: CGPoint(x: w * 0.41, y: h * 0.62))
        return path
    }
}
