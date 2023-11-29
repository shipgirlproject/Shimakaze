const std = @import("std");
const json = std.json;
const mem = std.mem;
const string = @import("./util.zig").string;
const codes = @import("./codes.zig");
const Opcodes = codes.Opcodes;
const Event = codes.Event;
const objects = @import("./objects.zig");

pub const EventPayload = struct {
    op: Opcodes,
    // we ignore d until we know what type of op it is
    // d: null,
    s: ?u16,
    t: ?Event,
};

pub fn parseEvent(allocator: mem.Allocator, payload: string) !EventPayload {
    var parsed_payload = try json.parseFromSlice(EventPayload, allocator, payload, .{ .ignore_unknown_fields = true });
    defer parsed_payload.deinit();
    return parsed_payload.value;
}

test "parse event payload" {
    const testing = std.testing;

    const payload =
        \\{
        \\    "op": 0,
        \\    "d": {},
        \\    "s": 42,
        \\    "t": "HELLO"
        \\}
    ;

    const parsed = try parseEvent(testing.allocator, payload);

    try testing.expect(parsed.op == Opcodes.Dispatch);
    try testing.expect(parsed.s == 42);
    try testing.expect(parsed.t.? == codes.Event.HELLO);
}

// Receive events
pub const DispatchPayload = struct {
    sequence: u16,
};

pub const HelloPayload = struct {
    heartbeat_interval: u16,
};

pub const ReadyPayload = struct {
    v: u8,
    // ignore the user object
    // user: null,
    guilds: []objects.UnavailableGuild,
    session_id: string,
    resume_gateway_url: string,
    shard: ?[]struct { u8, u8 },
    // ignore application
    // application: null,
};

pub const InvalidSessionPayload = bool;

pub const IgnoredPayload = @TypeOf(null);

pub const ReceivePayload = struct {
    op: ?Opcodes,
    event: ?Event,
    payload: union {
        hello: HelloPayload,
        ready: ReadyPayload,
        reconnect: IgnoredPayload,
        invalid_session: InvalidSessionPayload,
        other: string,
    },
};

fn parsePayload(comptime T: type, allocator: mem.Allocator, payload: string) !T {
    const parsed = try json.parseFromSlice(struct { d: T }, allocator, payload, .{ .ignore_unknown_fields = true });
    defer parsed.deinit();
    return parsed.value.d;
}

fn parseOther(allocator: mem.Allocator, payload: string) !string {
    return parsePayload(string, allocator, payload);
}

fn parseHello(allocator: mem.Allocator, payload: string) !HelloPayload {
    return parsePayload(HelloPayload, allocator, payload);
}

fn parseReady(allocator: mem.Allocator, payload: string) !ReadyPayload {
    return parsePayload(ReadyPayload, allocator, payload);
}

fn parseReconnect(allocator: mem.Allocator, payload: string) !IgnoredPayload {
    _ = payload;
    _ = allocator;
    return null;
}

fn parseInvalidSession(allocator: mem.Allocator, payload: string) !InvalidSessionPayload {
    return parsePayload(InvalidSessionPayload, allocator, payload);
}

test "parse hello payload" {
    const testing = std.testing;

    const payload =
        \\ {
        \\     "op": 10,
        \\     "d": {
        \\         "heartbeat_interval": 45000
        \\     }
        \\ }
    ;

    const parsed = try parseHello(testing.allocator, payload);
    try testing.expect(parsed.heartbeat_interval == 45000);
}

test "stringify resume payload" {}
