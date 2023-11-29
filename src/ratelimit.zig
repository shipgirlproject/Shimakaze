const std = @import("std");
const time = std.time;

// https://discord.com/developers/docs/topics/gateway#rate-limiting
pub const wait_time: i64 = 60;

// seems like a safe amount
pub const max_req_amount: u8 = 100;

pub const Ratelimiter = struct {
    refresh_time: i64,
    counter: u8,

    pub fn init() !Ratelimiter {
        return Ratelimiter{
            .refresh_time = time.timestamp(),
            .counter = max_req_amount,
        };
    }

    pub fn remove(self: *Ratelimiter) !u8 {
        if (time.timestamp() > self.refresh_time) {
            self.counter = max_req_amount;
        }

        if (self.counter > 0) {
            self.counter -= 1;
            return self.counter;
        }

        return error.QuotaExhausted;
    }
};

test "ratelimiter" {}
