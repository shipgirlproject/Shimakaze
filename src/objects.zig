const string = @import("./util.zig").string;

pub const UnavailableGuild = struct {
    id: string,
    unavailable: bool,
};
