const std = @import("std");
const util = @import("./util.zig");
const string = util.string;

const env_prefix = "SHIMAKAZE_";

const AppEnv = struct {
    token: string,
};

pub fn getEnv() !AppEnv {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const env_map: *std.process.EnvMap = try arena.allocator().create(std.process.EnvMap);
    env_map.* = try std.process.getEnvMap(arena.allocator());

    const env_token = env_map.get(env_prefix + "TOKEN") orelse return error.BAD_ENV_TOKEN;

    return AppEnv{
        .token = env_token,
    };
}
