const std = @import("std");
const ws = @import("websocket");
const Client = ws.Client;

pub const Handler = struct {
    client: Client,

    pub fn init(allocator: std.mem.Allocator, host: []const u8, port: u16) !Handler {
        return .{
            .client = try ws.connect(allocator, host, port, .{}),
        };
    }

    pub fn deinit(self: *Handler) void {
        self.client.deinit();
    }

    pub fn connect(self: *Handler, path: []const u8) !void {
        try self.client.handshake(path, .{ .timeout_ms = 5000 });
        const thread = try self.client.readLoopInNewThread(self);
        thread.detach();
    }

    pub fn handle(_: Handler, message: ws.Message) !void {
        const data = message.data;
        std.debug.print("CLIENT GOT: {any}\n", .{data});
    }

    pub fn write(self: *Handler, data: []u8) !void {
        return self.client.write(data);
    }

    pub fn close(_: Handler) void {}
};
