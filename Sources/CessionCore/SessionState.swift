import Foundation

/// Mirrors the `status` Claude Code writes to `~/.claude/sessions/<pid>.json`.
///
/// That file is not a public API, so an unrecognized value degrades to `unknown`
/// instead of failing: the tab list has to keep working when the status does not.
/// `waiting` is the only state blocked on the user; `idle` just has nothing to do.
public enum SessionState: Sendable, Equatable {
    case running
    case waiting
    case idle
    case unknown

    public init(rawStatus: String?) {
        switch rawStatus {
        case "busy": self = .running
        case "waiting": self = .waiting
        case "idle": self = .idle
        default: self = .unknown
        }
    }
}
