import SwiftUI

/// Original three-quarter view of a closed fabric wrist band with a broad, screenless sensor clasp.
/// Normalized paths describe the object rather than vendor artwork. The caller owns size and tint.
public struct StrapBandGlyph: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        // The rear fabric loop wraps around the wrist behind the front sensor housing.
        path.move(to: CGPoint(x: w * 0.50, y: h * 0.10))
        path.addCurve(to: CGPoint(x: w * 0.14, y: h * 0.49),
                      control1: CGPoint(x: w * 0.23, y: h * 0.07),
                      control2: CGPoint(x: w * 0.13, y: h * 0.25))
        path.addCurve(to: CGPoint(x: w * 0.43, y: h * 0.92),
                      control1: CGPoint(x: w * 0.14, y: h * 0.74),
                      control2: CGPoint(x: w * 0.23, y: h * 0.91))
        path.addCurve(to: CGPoint(x: w * 0.79, y: h * 0.66),
                      control1: CGPoint(x: w * 0.66, y: h * 0.96),
                      control2: CGPoint(x: w * 0.77, y: h * 0.85))
        // A second fabric edge gives the loop width instead of reading as a single wire or watch.
        path.move(to: CGPoint(x: w * 0.49, y: h * 0.27))
        path.addCurve(to: CGPoint(x: w * 0.32, y: h * 0.54),
                      control1: CGPoint(x: w * 0.34, y: h * 0.27),
                      control2: CGPoint(x: w * 0.31, y: h * 0.38))
        path.addCurve(to: CGPoint(x: w * 0.52, y: h * 0.76),
                      control1: CGPoint(x: w * 0.33, y: h * 0.69),
                      control2: CGPoint(x: w * 0.41, y: h * 0.77))
        // The broad, slightly slanted clasp has no inset face or display.
        path.move(to: CGPoint(x: w * 0.50, y: h * 0.10))
        path.addQuadCurve(to: CGPoint(x: w * 0.79, y: h * 0.15),
                         control: CGPoint(x: w * 0.66, y: h * 0.10))
        path.addQuadCurve(to: CGPoint(x: w * 0.88, y: h * 0.63),
                         control: CGPoint(x: w * 0.91, y: h * 0.34))
        path.addQuadCurve(to: CGPoint(x: w * 0.53, y: h * 0.66),
                         control: CGPoint(x: w * 0.70, y: h * 0.67))
        path.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.10),
                         control: CGPoint(x: w * 0.47, y: h * 0.37))
        path.closeSubpath()
        // Short cross seam where the fabric meets the clasp, not a watch crown.
        path.move(to: CGPoint(x: w * 0.53, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.87, y: h * 0.52))
        return path
    }
}
