import Foundation

/// A finished screen recording saved on the device.
nonisolated struct Recording: Identifiable, Hashable, Sendable {
    let url: URL
    let createdAt: Date
    let duration: TimeInterval
    let fileSize: Int64

    var id: String { url.lastPathComponent }
}
