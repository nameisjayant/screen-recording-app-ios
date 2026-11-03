// Renders the RecQuest app icons (Prod + Beta, light/dark/tinted) into the asset catalog.
// Usage: swift scripts/generate_app_icon.swift
// The artwork mirrors `AppLogoMark` in Common/Components so the icon and in-app logo stay identical.

import AppKit
import SwiftUI

let assets = URL(fileURLWithPath: "Screen Recorder/Resources/Assets.xcassets")

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}

struct Sparkle: Shape {
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        let inner = r * 0.28
        var p = Path()
        for i in 0..<8 {
            let angle = Double(i) * .pi / 4 - .pi / 2
            let radius = i.isMultiple(of: 2) ? r : inner
            let point = CGPoint(x: c.x + cos(angle) * radius, y: c.y + sin(angle) * radius)
            i == 0 ? p.move(to: point) : p.addLine(to: point)
        }
        p.closeSubpath()
        return p
    }
}

struct Smile: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control: CGPoint(x: rect.midX, y: rect.maxY * 1.4))
        return p
    }
}

enum Variant { case light, dark, tinted }

struct IconArt: View {
    let variant: Variant
    let beta: Bool

    private var tinted: Bool { variant == .tinted }
    private func tone(_ hex: UInt32, gray: Double) -> Color { tinted ? Color(white: gray) : Color(hex: hex) }

    var body: some View {
        ZStack {
            if variant == .light {
                LinearGradient(colors: [Color(hex: 0x8F5BFF), Color(hex: 0x4A1FCF), Color(hex: 0x22105E)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                RadialGradient(colors: [Color.white.opacity(0.28), .clear],
                               center: UnitPoint(x: 0.2, y: 0.12), startRadius: 0, endRadius: 520)
            }

            foreground
                .offset(x: -36, y: 8)

            if beta {
                Text("BETA")
                    .font(.system(size: 92, weight: .black, design: .rounded))
                    .kerning(8)
                    .foregroundStyle(tone(0x13104A, gray: 0.15))
                    .frame(width: 760, height: 136)
                    .background(tone(0xFFC93C, gray: 0.95))
                    .rotationEffect(.degrees(45))
                    .offset(x: -300, y: 300)
            }
        }
        .frame(width: 1024, height: 1024)
        .clipped()
    }

    private var foreground: some View {
        ZStack {
            // Chunky "screen" tile with a 3D game-button base.
            RoundedRectangle(cornerRadius: 120, style: .continuous)
                .fill(tone(0xB9A3FF, gray: 0.55))
                .frame(width: 640, height: 520)
                .offset(y: 34)
            RoundedRectangle(cornerRadius: 120, style: .continuous)
                .fill(tone(0xFFFFFF, gray: 1))
                .frame(width: 640, height: 520)

            // Record button.
            Circle()
                .stroke(tone(0xFF4D6D, gray: 0.85).opacity(0.25), lineWidth: 34)
                .frame(width: 330, height: 330)
            Circle()
                .fill(LinearGradient(colors: [tone(0xFF7A8F, gray: 0.8), tone(0xFF3355, gray: 0.7)],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: 236, height: 236)
            Circle()
                .fill(Color.white.opacity(0.55))
                .frame(width: 62, height: 62)
                .offset(x: -54, y: -54)

            // Sparkles.
            Sparkle()
                .fill(tone(0xFFC93C, gray: 0.95))
                .frame(width: 170, height: 170)
                .offset(x: 300, y: -250)
            Sparkle()
                .fill(tone(0xFFC93C, gray: 0.95))
                .frame(width: 80, height: 80)
                .offset(x: 205, y: -330)

            // Face cam bubble.
            ZStack {
                Circle().fill(tone(0x1E9E8A, gray: 0.5)).offset(y: 16)
                Circle().fill(tone(0x2DE1C2, gray: 0.9))
                Circle().stroke(tone(0xFFFFFF, gray: 1), lineWidth: 18)
                HStack(spacing: 46) {
                    Capsule().frame(width: 26, height: 40)
                    Capsule().frame(width: 26, height: 40)
                }
                .foregroundStyle(tone(0x13104A, gray: 0.2))
                .offset(y: -20)
                Smile()
                    .stroke(tone(0x13104A, gray: 0.2), style: StrokeStyle(lineWidth: 18, lineCap: .round))
                    .frame(width: 92, height: 46)
                    .offset(y: 42)
            }
            .frame(width: 250, height: 250)
            .offset(x: 270, y: 250)
        }
    }
}

@MainActor
func render(_ view: some View, to url: URL) throws {
    let renderer = ImageRenderer(content: view)
    renderer.scale = 1
    guard let cg = renderer.cgImage else { throw CocoaError(.fileWriteUnknown) }
    let rep = NSBitmapImageRep(cgImage: cg)
    guard let data = rep.representation(using: .png, properties: [:]) else { throw CocoaError(.fileWriteUnknown) }
    try data.write(to: url)
}

func contents(prefix: String) -> String {
    """
    {
      "images" : [
        { "filename" : "\(prefix)-light.png", "idiom" : "universal", "platform" : "ios", "size" : "1024x1024" },
        { "appearances" : [ { "appearance" : "luminosity", "value" : "dark" } ],
          "filename" : "\(prefix)-dark.png", "idiom" : "universal", "platform" : "ios", "size" : "1024x1024" },
        { "appearances" : [ { "appearance" : "luminosity", "value" : "tinted" } ],
          "filename" : "\(prefix)-tinted.png", "idiom" : "universal", "platform" : "ios", "size" : "1024x1024" }
      ],
      "info" : { "author" : "xcode", "version" : 1 }
    }
    """
}

MainActor.assumeIsolated {
    do {
        for (set, beta) in [("AppIcon", false), ("AppIcon-Beta", true)] {
            let dir = assets.appendingPathComponent("\(set).appiconset")
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let prefix = beta ? "icon-beta" : "icon"
            try render(IconArt(variant: .light, beta: beta), to: dir.appendingPathComponent("\(prefix)-light.png"))
            try render(IconArt(variant: .dark, beta: beta), to: dir.appendingPathComponent("\(prefix)-dark.png"))
            try render(IconArt(variant: .tinted, beta: beta), to: dir.appendingPathComponent("\(prefix)-tinted.png"))
            try contents(prefix: prefix).write(to: dir.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
        }
        print("Icons written to \(assets.path)")
    } catch {
        print("Failed: \(error)")
        exit(1)
    }
}
