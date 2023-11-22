const std = @import("std");
const xev = @import("xev");

// https://discord.com/developers/docs/topics/gateway#rate-limiting
// 60 seconds as nanoseconds
// avoid overflow: https://github.com/ziglang/zig/issues/13123#issue-1403103093
pub const wait_time = @as(u64, 60) * std.time.ns_per_s;

// seems like a safe amount
pub const max_req_amount = 100;

pub const Ratelimiter = struct {
    var counter: u8 = 0;
    var loop = xev.Loop;
    var timer = xev.Timer;

    pub fn init() !Ratelimiter {
        counter = max_req_amount;

        loop = try xev.Loop.init(.{});
        defer loop.deinit();

        var c: xev.Completion = undefined;
        timer = try xev.Timer.init();
        timer.run(&loop, &c, wait_time, void, null, _callback);

        try loop.run(.until_done);
    }

    fn _callback(
        _: ?*void,
        _: *xev.Loop,
        _: *xev.Completion,
        result: xev.Timer.RunError!void,
    ) xev.CallbackAction {
        _ = result catch unreachable;
        // refill
        counter = max_req_amount;
        return .rearm;
    }

    pub fn deinit() void {
        loop.stop();
    }

    pub fn remove() !u8 {
        if (counter > 0) {
            counter -= 1;
            return counter;
        }

        return error.QuotaExhausted;
    }
};

test "ratelimiter" {
    const limiter = try Ratelimiter.init();
    defer limiter.deinit();
}
