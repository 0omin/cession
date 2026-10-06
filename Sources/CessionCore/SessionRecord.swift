import Foundation

/// One `~/.claude/sessions/<pid>.json` file.
///
/// Claude Code owns this file and it is not a public API, so every field except
/// `pid` is optional and unknown keys are ignored. A schema change should cost us
/// status, not the ability to list and jump to tabs.
public struct SessionRecord: Decodable, Equatable, Sendable {
    public let pid: Int
    public let sessionId: String?
    public let cwd: String?
    public let name: String?
    public let status: String?
    public let waitingFor: String?
    public let procStart: String?

    public var state: SessionState { SessionState(rawStatus: status) }

    /// `/rename` sets `name`, so it is the most specific label available.
    public var displayName: String {
        if let name, !name.isEmpty { return name }
        if let sessionId, !sessionId.isEmpty { return String(sessionId.prefix(8)) }
        return "pid \(pid)"
    }

    public static func decode(from data: Data) throws -> SessionRecord {
        try JSONDecoder().decode(SessionRecord.self, from: data)
    }
}
