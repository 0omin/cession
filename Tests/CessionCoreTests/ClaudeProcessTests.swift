import Foundation
import Testing
@testable import CessionCore

private let seoul = TimeZone(identifier: "Asia/Seoul")!

@Test func parsesPsOutput() {
    let out = """
    PID STARTED                      TTY      COMM
    95169 Wed Sep 23 15:05:20 2026     ttys000  claude
    27491 Tue Sep 22 21:54:03 2026     ttys001  claude
    """
    let ps = ClaudeProcess.parse(psOutput: out, timeZone: seoul)

    #expect(ps.count == 2)
    #expect(ps[0].pid == 95169)
    #expect(ps[0].tty == "/dev/ttys000")
    #expect(ps[1].pid == 27491)
}

@Test func skipsProcessesWithoutATty() {
    let out = """
    PID STARTED                      TTY      COMM
    19291 Thu Sep 17 09:02:11 2026     ??       claude
    """
    #expect(ClaudeProcess.parse(psOutput: out, timeZone: seoul).isEmpty)
}

@Test func skipsOtherPrograms() {
    let out = """
    PID STARTED                      TTY      COMM
    1 Thu Sep 10 11:35:08 2026     ??       /sbin/launchd
    2841 Thu Sep 17 09:02:11 2026     ttys003  zsh
    4242 Thu Sep 17 09:02:11 2026     ttys004  notclaude
    """
    #expect(ClaudeProcess.parse(psOutput: out, timeZone: seoul).isEmpty)
}

@Test func toleratesEmptyAndHeaderOnlyOutput() {
    #expect(ClaudeProcess.parse(psOutput: "", timeZone: seoul).isEmpty)
    #expect(ClaudeProcess.parse(psOutput: "PID STARTED TTY COMM", timeZone: seoul).isEmpty)
}

@Test func handlesSingleDigitDayPadding() {
    // ps pads a single-digit day with two spaces: "Oct  6", not "Oct 6".
    let out = """
    PID STARTED                      TTY      COMM
    73256 Tue Oct  6 15:52:30 2026     ttys002  claude
    """
    let ps = ClaudeProcess.parse(psOutput: out, timeZone: seoul)
    #expect(ps.count == 1)
    #expect(ps[0].pid == 73256)
}

@Test func procStartIsReadAsUTC() throws {
    let d = try #require(ClaudeProcess.parseProcStart("Tue Oct  6 06:52:30 2026"))
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(identifier: "UTC")!
    let c = cal.dateComponents([.year, .month, .day, .hour, .minute], from: d)
    #expect(c.year == 2026)
    #expect(c.month == 10)
    #expect(c.day == 6)
    #expect(c.hour == 6)
    #expect(c.minute == 52)
}

@Test func theTwoSourcesDescribeTheSameInstant() throws {
    // The whole point of this type. The session file stamps UTC while ps prints
    // local time, so comparing the strings would never match and every session
    // would look like a recycled pid. Observed on 16 live sessions in Asia/Seoul.
    let out = """
    PID STARTED                      TTY      COMM
    73256 Tue Oct  6 15:52:30 2026     ttys002  claude
    """
    let fromPs = try #require(ClaudeProcess.parse(psOutput: out, timeZone: seoul).first)
    let fromJson = try #require(ClaudeProcess.parseProcStart("Tue Oct  6 06:52:30 2026"))

    #expect(fromPs.started == fromJson)
    #expect("Tue Oct  6 15:52:30 2026" != "Tue Oct  6 06:52:30 2026")
}

@Test func unparsableTimestampDropsTheRowRatherThanGuessing() {
    let out = """
    PID STARTED                      TTY      COMM
    4242 not a real timestamp here     ttys005  claude
    """
    #expect(ClaudeProcess.parse(psOutput: out, timeZone: seoul).isEmpty)
}
