import Foundation

/// A live `claude` process as `ps` sees it.
///
/// `ps` is the source of truth for which sessions exist. Session files are removed
/// on a clean exit but survive a kill, so trusting them alone would show ghosts.
public struct ClaudeProcess: Equatable, Sendable {
    public let pid: Int
    public let tty: String
    public let started: Date

    public init(pid: Int, tty: String, started: Date) {
        self.pid = pid
        self.tty = tty
        self.started = started
    }

    /// Both sources pad a single-digit day with two spaces ("Oct  6"), which the
    /// formatter will not accept, so runs of whitespace are collapsed first.
    private static func parse(_ stamp: String, in zone: TimeZone) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = zone
        f.dateFormat = "EEE MMM d HH:mm:ss yyyy"
        let normalized = stamp.split(separator: " ", omittingEmptySubsequences: true)
            .joined(separator: " ")
        return f.date(from: normalized)
    }

    /// The `procStart` field of a session file, which is stamped in UTC.
    public static func parseProcStart(_ stamp: String) -> Date? {
        parse(stamp, in: TimeZone(identifier: "UTC")!)
    }

    /// Output of `ps -Ao pid,lstart,tty,comm`, whose `lstart` is local time.
    ///
    /// A row we cannot fully parse is dropped: a session missing from the list is
    /// recoverable, a session with a wrong start time silently breaks the pid join.
    public static func parse(psOutput: String, timeZone: TimeZone = .current) -> [ClaudeProcess] {
        psOutput.split(separator: "\n").dropFirst().compactMap { line in
            let fields = line.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
            guard fields.count >= 8,
                  let pid = Int(fields[0]),
                  fields[6] != "??",
                  fields[7].split(separator: "/").last == "claude",
                  let started = parse(fields[1...5].joined(separator: " "), in: timeZone)
            else { return nil }

            return ClaudeProcess(pid: pid, tty: "/dev/" + fields[6], started: started)
        }
    }
}
