import Testing
@testable import CessionCore

@Test func mapsClaudeCodeStatusStrings() {
    #expect(SessionState(rawStatus: "busy") == .running)
    #expect(SessionState(rawStatus: "waiting") == .waiting)
    #expect(SessionState(rawStatus: "idle") == .idle)
}

@Test func unknownStatusDoesNotCrash() {
    // "shell" is a real value we observed but cannot interpret. Claude Code is free
    // to add more, so anything unrecognized has to be survivable.
    #expect(SessionState(rawStatus: "shell") == .unknown)
    #expect(SessionState(rawStatus: nil) == .unknown)
    #expect(SessionState(rawStatus: "") == .unknown)
}
