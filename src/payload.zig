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
    s: ?u32,
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
pub const DispatchPayload = string;

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

pub fn parsePayload(comptime T: type, allocator: mem.Allocator, payload: string) !T {
    const parsed = try json.parseFromSlice(struct { d: T }, allocator, payload, .{ .ignore_unknown_fields = true });
    defer parsed.deinit();
    return parsed.value.d;
}

pub fn parseOther(allocator: mem.Allocator, payload: string) !string {
    return parsePayload(string, allocator, payload);
}

pub fn parseHello(allocator: mem.Allocator, payload: string) !HelloPayload {
    return parsePayload(HelloPayload, allocator, payload);
}

pub fn parseReady(allocator: mem.Allocator, payload: string) !ReadyPayload {
    return parsePayload(ReadyPayload, allocator, payload);
}

pub fn parseReconnect(allocator: mem.Allocator, payload: string) !IgnoredPayload {
    _ = payload;
    _ = allocator;
    return null;
}

pub fn parseInvalidSession(allocator: mem.Allocator, payload: string) !InvalidSessionPayload {
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

// send events
pub const IdentifyPayload = struct {
    token: string,
    properties: struct {
        os: string,
        browser: string,
        device: string,
    },
    compress: ?bool,
    large_threshold: ?u8,
    shard: ?[2]u8,
    presence: ?PresenceUpdatePayload,
    intents: u32,
};

pub const ResumePayload = struct {
    token: string,
    session_id: string,
    seq: ?u32,
};

pub const HeartbeatPayload = ?u32;

pub const RequestGuildMembersPayload = struct {
    guild_id: string,
    query: ?string,
    limit: u32,
    presences: ?bool,
    user_ids: ?[]string,
    nonce: ?string,
};

pub const VoiceStateUpdatePayload = struct {
    guild_id: string,
    channel_id: ?string,
    self_mute: bool,
    self_deaf: bool,
};

pub const PresenceUpdatePayload = struct {
    since: ?i64,
    activities: []struct {
        name: string,
        state: ?string,
        type: u8,
        url: ?string,
    },
    status: string,
    afk: bool,
};

pub fn stringifyEvent(allocator: mem.Allocator, opcode: Opcodes, payload: anytype) !string {
    const value = .{ .op = @intFromEnum(opcode), .d = payload };
    return json.stringifyAlloc(allocator, value, .{});
}

test "stringify event payload" {}

pub fn stringifyIdentify(allocator: mem.Allocator, payload: IdentifyPayload) !string {
    return stringifyEvent(allocator, Opcodes.Identify, payload);
}

pub fn strinigfyResume(allocator: mem.Allocator, payload: ResumePayload) !string {
    return stringifyEvent(allocator, Opcodes.Resume, payload);
}

pub fn stringifyHeartbeat(allocator: mem.Allocator, payload: HeartbeatPayload) !string {
    return stringifyEvent(allocator, Opcodes.Heartbeat, payload);
}

pub fn stringifyRequestGuildMembers(allocator: mem.Allocator, payload: RequestGuildMembersPayload) !string {
    return stringifyEvent(allocator, Opcodes.RequestGuildMembers, payload);
}

pub fn stringifyVoiceStateUpdate(allocator: mem.Allocator, payload: VoiceStateUpdatePayload) !string {
    return stringifyEvent(allocator, Opcodes.VoiceStateUpdate, payload);
}

pub fn stringifyPresenceUpdate(allocator: mem.Allocator, payload: PresenceUpdatePayload) !string {
    return stringifyEvent(allocator, Opcodes.PresenceUpdate, payload);
}

test "stringify resume payload" {}
