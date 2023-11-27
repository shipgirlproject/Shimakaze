const std = @import("std");
const xev = @import("xev");

// https://discord.com/developers/docs/topics/gateway#rate-limiting
// 60 seconds as nanoseconds
// avoid overflow: https://github.com/ziglang/zig/issues/13123#issue-1403103093
pub const wait_time = @as(u64, 60) * std.time.ns_per_s;

// seems like a safe amount
pub const max_req_amount = 100;

// better loop/timer/delay impl using zig stdlib in future, but for now this is a poc type thing
pub const Ratelimiter = struct {
    loop: xev.Loop,
    timer: xev.Timer,

    var counter: u8 = max_req_amount;
    var stop_timer = false;

    pub fn init() !Ratelimiter {
        var loop = try xev.Loop.init(.{});

        var c: xev.Completion = undefined;
        var timer = try xev.Timer.init();
        timer.run(&loop, &c, wait_time, u8, &counter, _callback);

        try loop.run(.until_done);

        return Ratelimiter{
            .loop = loop,
            .timer = timer,
        };
    }

    fn _callback(
        data: ?*u8,
        _: *xev.Loop,
        _: *xev.Completion,
        result: xev.Timer.RunError!void,
    ) xev.CallbackAction {
        _ = result catch unreachable;
        // refill
        data.?.* = max_req_amount;

        // FIXME: this does not actually break out of the loop
        if (stop_timer) return .disarm;
        return .rearm;
    }

    pub fn stop(self: *Ratelimiter) void {
        stop_timer = true;
        self.loop.stop();
    }

    pub fn deinit(self: *Ratelimiter) void {
        self.loop.deinit();
        self.timer.deinit();
    }

    pub fn remove(self: *Ratelimiter) !u8 {
        if (self.counter > 0) {
            self.counter -= 1;
            return self.counter;
        }

        return error.QuotaExhausted;
    }
};

test "ratelimiter" {
    // FIXME: infinite loop, cannot cut off
    var limiter = try Ratelimiter.init();
    limiter.stop();
    defer limiter.deinit();
}
