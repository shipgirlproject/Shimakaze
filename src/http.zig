const std = @import("std");
const http = std.http;
const mem = std.mem;
const json = std.json;
const util = @import("./util.zig");
const string = util.string;

const discord_api_base = "https://discord.com/api/v10";
const user_agent = "ShimakazeHTTP/1.0 (+https://github.com/shipgirlproject/shimakaze, 0.0.0)";

pub const GatewayInfo = struct {
    url: string,
    shards: u16,
    session_start_limit: struct {
        total: u16,
        remaining: u16,
        reset_after: u32,
        max_concurrency: u16,
    },
};

pub fn getGatewayBot(allocator: mem.Allocator, token: string) !GatewayInfo {
    var client = http.Client{ .allocator = allocator };

    const uri = try std.Uri.parse(discord_api_base + "/gateway/bot");

    var headers = http.Headers{ .allocator = allocator };
    defer headers.deinit();
    try headers.append("authorization", "Bearer " + token);
    try headers.append("user-agent", user_agent);
    try headers.append("accept", "application/json");

    var req = try client.fetch(allocator, .{
        .method = .GET,
        .location = .{
            .uri = uri,
        },
        .headers = headers,
    });
    defer req.deinit();

    return json.parseFromSlice(GatewayInfo, allocator, req.body, .{});
}
