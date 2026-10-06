import Foundation
import Testing
@testable import CessionCore

private func data(_ s: String) -> Data { Data(s.utf8) }

@Test func decodesASessionFile() throws {
    let json = """
    {"pid":4242,"sessionId":"11111111-2222-3333-4444-555555555555",
     "cwd":"/Users/example/work/widget","name":"widget","nameSource":"user",
     "status":"busy","procStart":"Wed Sep 16 12:37:57 2026",
     "startedAt":1789562280131,"version":"2.1.273","kind":"interactive"}
    """
    let r = try SessionRecord.decode(from: data(json))
    #expect(r.pid == 4242)
    #expect(r.name == "widget")
    #expect(r.cwd == "/Users/example/work/widget")
    #expect(r.procStart == "Wed Sep 16 12:37:57 2026")
    #expect(r.state == .running)
}

@Test func ignoresUnknownFields() throws {
    let json = #"{"pid":1,"status":"idle","somethingAddedLater":{"a":[1,2]}}"#
    let r = try SessionRecord.decode(from: data(json))
    #expect(r.pid == 1)
    #expect(r.state == .idle)
}

@Test func survivesMissingOptionalFields() throws {
    let r = try SessionRecord.decode(from: data(#"{"pid":7}"#))
    #expect(r.pid == 7)
    #expect(r.name == nil)
    #expect(r.state == .unknown)
}

@Test func carriesWaitingReason() throws {
    let json = #"{"pid":2,"status":"waiting","waitingFor":"permission prompt"}"#
    let r = try SessionRecord.decode(from: data(json))
    #expect(r.state == .waiting)
    #expect(r.waitingFor == "permission prompt")
}

@Test func displayNamePrefersName() throws {
    let json = #"{"pid":4,"sessionId":"11111111-2222-3333","name":"docs-site"}"#
    #expect(try SessionRecord.decode(from: data(json)).displayName == "docs-site")
}

@Test func displayNameFallsBackToShortSessionId() throws {
    let json = #"{"pid":3,"sessionId":"11111111-2222-3333-4444-555555555555"}"#
    #expect(try SessionRecord.decode(from: data(json)).displayName == "11111111")
}

@Test func displayNameFallsBackToPid() throws {
    #expect(try SessionRecord.decode(from: data(#"{"pid":5}"#)).displayName == "pid 5")
}

@Test func emptyStringsAreTreatedAsAbsent() throws {
    let json = #"{"pid":6,"sessionId":"","name":""}"#
    #expect(try SessionRecord.decode(from: data(json)).displayName == "pid 6")
}

@Test func brokenJsonThrows() {
    #expect(throws: (any Error).self) {
        try SessionRecord.decode(from: data("{not json"))
    }
}
