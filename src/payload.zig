const std = @import("std");
const json = std.json;
const mem = std.mem;
const string = @import("./util.zig").string;
const codes = @import("./codes.zig");
const Opcodes = codes.Opcodes;
const Event = codes.Event;
const objects = @import("/objects.zig");

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

fn parsePayload(T: type, allocator: mem.Allocator, payload: string) !T {
    const parsed = try json.parseFromSlice(struct { d: T }, allocator, payload, .{ .ignore_unknown_fields = true });
    defer parsed.deinit();
    return parsed.value.d;
}

pub fn parseRecievePayload(allocator: mem.Allocator, payload: string) !ReceivePayload {
    const event = try parseEvent(allocator, payload);
    return switch (event.op) {
        .Dispatch => switch (event.t) {},
        .Hello => ReceivePayload{
            .op = event.op,
            .payload = .{
                .hello = try parsePayload(HelloPayload, allocator, payload),
            },
        },
        else => ReceivePayload{
            .op = event.op,
            .payload = .{
                .other = try parsePayload(string, allocator, payload),
            },
        },
    };
}

test "stringify resume payload" {}
