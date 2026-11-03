import SwiftUI
import Testing
@testable import Screen_Recorder

struct ColorThemeTests {
    /// UIKit resolves dynamic colors off the main thread when the theme changes;
    /// this used to crash because the provider was main-actor isolated.
    @Test func dynamicColorResolvesOffMainThread() async {
        let provider = Color.dynamicProvider(light: 0xFFFFFF, dark: 0x000000)

        let (light, dark) = await Task.detached {
            let light = provider(UITraitCollection(userInterfaceStyle: .light))
            let dark = provider(UITraitCollection(userInterfaceStyle: .dark))
            return (light.cgColor.components ?? [], dark.cgColor.components ?? [])
        }.value

        #expect(light.prefix(3) == [1, 1, 1])
        #expect(dark.prefix(3) == [0, 0, 0])
    }
}
