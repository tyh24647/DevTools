import SwiftUI

/// Uses the same material, continuous corners and capsule labels as RegexDojo.
struct Card<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .roundedRectShadow(cornerRadius: 18, radius: 8, x: 0, y: 4, color: .black.opacity(0.12))
    }
}

struct Pill: View {
    let text: String
    let symbol: String

    var body: some View {
        Label(text, systemImage: symbol)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.quaternary, in: Capsule())
    }
}

struct ProBadge: View {
    var body: some View {
        Text("PRO")
            .font(.caption2.bold())
            .foregroundStyle(.purple)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.purple.opacity(0.12), in: Capsule())
    }
}

// MARK: - Efficient rounded-rect shadow with fixed shadowPath
private struct RoundedRectShadow: ViewModifier {
    let cornerRadius: CGFloat
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    let color: Color

    func body(content: Content) -> some View {
        content
            .background(ShadowPathView(cornerRadius: cornerRadius, shadowColor: UIColor(color), shadowRadius: radius, shadowOffset: CGSize(width: x, height: y)))
    }
}

#if canImport(UIKit)
import UIKit
private struct ShadowPathView: UIViewRepresentable {
    let cornerRadius: CGFloat
    let shadowColor: UIColor
    let shadowRadius: CGFloat
    let shadowOffset: CGSize

    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = false
        v.layer.masksToBounds = false
        v.layer.shouldRasterize = false
        return v
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.layer.shadowColor = shadowColor.cgColor
        uiView.layer.shadowOpacity = 1
        uiView.layer.shadowRadius = shadowRadius
        uiView.layer.shadowOffset = shadowOffset
        let path = UIBezierPath(roundedRect: uiView.bounds, cornerRadius: cornerRadius).cgPath
        uiView.layer.shadowPath = path
    }
}
#elseif canImport(AppKit)
import AppKit
private struct ShadowPathView: NSViewRepresentable {
    let cornerRadius: CGFloat
    let shadowColor: NSColor
    let shadowRadius: CGFloat
    let shadowOffset: CGSize

    func makeNSView(context: Context) -> NSView {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.masksToBounds = false
        return v
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let layer = nsView.layer else { return }
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
        let path = CGPath(roundedRect: nsView.bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        layer.shadowPath = path
    }
}
#endif

extension View {
    func roundedRectShadow(cornerRadius: CGFloat, radius: CGFloat, x: CGFloat, y: CGFloat, color: Color) -> some View {
        modifier(RoundedRectShadow(cornerRadius: cornerRadius, radius: radius, x: x, y: y, color: color))
    }
}
