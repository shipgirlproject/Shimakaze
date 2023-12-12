const std = @import("std");
const util = @import("./util.zig");
const string = util.string;

const env_prefix = "SHIMAKAZE_";

const AppEnv = struct {
    token: string,
};

pub fn getEnv() !AppEnv {
    const env_map = try std.process.getEnvMap(std.heap.page_allocator);

    const env_token = env_map.get(env_prefix ++ "TOKEN") orelse return error.BadEnvToken;

    return AppEnv{
        .token = env_token,
    };
}

test "env" {
    const testing = std.testing;
    try testing.expectError(error.BadEnvToken, getEnv());
}
