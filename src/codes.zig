const std = @import("std");
const string = @import("./util.zig").string;

pub const Opcodes = enum(u8) {
    /// Recieve: An event was dispatched.
    Dispatch,
    /// Send/Receive: Fired periodically by the client to keep the connection alive.
    Heartbeat,
    /// Send: Starts a new session during the initial handshake.
    Identify,
    /// Send: Update the client's presence.
    PresenceUpdate,
    /// Send: Used to join/leave or move between voice channels.
    VoiceStateUpdate,
    /// Send: Resume a previous session that was disconnected.
    Resume = 6,
    /// Receive: You should attempt to reconnect and resume immediately.
    Reconnect,
    /// Send: Request information about offline guild members in a large guild.
    RequestGuildMembers,
    /// Receive: The session has been invalidated. You should reconnect and identify/resume accordingly.
    InvalidSession,
    /// Receive: Sent immediately after connecting, contains the heartbeat_interval to use.
    Hello,
    /// Receive: Sent in response to receiving a heartbeat to acknowledge that it has been received.
    HeartbeatAck,
};

pub const CloseCodes = enum(u8) {
    /// Reconnect: We're not sure what went wrong. Try reconnecting?
    UnknownError = 4000,
    /// Reconnect: You sent an invalid Gateway opcode or an invalid payload for an opcode. Don't do that!
    UnknownOpcode,
    /// Reconnect: You sent an invalid payload to Discord. Don't do that!
    DecodeError,
    /// Reconnect: You sent us a payload prior to identifying.
    NotAuthenticated,
    /// Stop: The account token sent with your identify payload is incorrect.
    AuthenticationFailed,
    /// Reconnect: You sent more than one identify payload. Don't do that!
    AlreadyAuthenticated,
    /// Reconnect: The sequence sent when resuming the session was invalid. Reconnect and start a new session.
    InvalidSeq = 4007,
    /// Reconnect: Woah nelly! You're sending payloads to us too quickly. Slow it down! You will be disconnected on receiving this.
    RateLimited,
    /// Reconnect: Your session timed out. Reconnect and start a new one.
    SessionTimedOut,
    /// Stop: You sent us an invalid shard when identifying.
    InvalidShard,
    /// Stop: The session would have handled too many guilds - you are required to shard your connection in order to connect.
    ShardingRequired,
    /// Stop: You sent an invalid version for the gateway.
    InvalidApiVersion,
    /// Stop: You sent an invalid intent for a Gateway Intent. You may have incorrectly calculated the bitwise value.
    InvalidIntents,
    /// Stop: You sent a disallowed intent for a Gateway Intent. You may have tried to specify an intent that you have not enabled or are not approved for.
    DisallowedIntents,
};

pub const Event = enum(u8) {
    HELLO,
    READY,
    RESUMED,
    RECONNECT,
    INVALID_SESSION,
    APPLICATION_COMMAND_PERMISSIONS_UPDATE,
    AUTO_MODERATION_RULE_CREATE,
    AUTO_MODERATION_RULE_UPDATE,
    AUTO_MODERATION_RULE_DELETE,
    AUTO_MODERATION_ACTION_EXECUTION,
    CHANNEL_CREATE,
    CHANNEL_UPDATE,
    CHANNEL_DELETE,
    CHANNEL_PINS_UPDATE,
    THREAD_CREATE,
    THREAD_UPDATE,
    THREAD_DELETE,
    THREAD_LIST_SYNC,
    THREAD_MEMBER_UPDATE,
    THREAD_MEMBERS_UPDATE,
    ENTITLEMENT_CREATE,
    ENTITLEMENT_UPDATE,
    ENTITLEMENT_DELETE,
    GUILD_CREATE,
    GUILD_UPDATE,
    GUILD_DELETE,
    GUILD_AUDIT_LOG_ENTRY_CREATE,
    GUILD_BAN_ADD,
    GUILD_BAN_REMOVE,
    GUILD_EMOJIS_UPDATE,
    GUILD_STICKERS_UPDATE,
    GUILD_INTERGRATIONS_UPDATE,
    GUILD_MEMBER_ADD,
    GUILD_MEMBER_REMOVE,
    GUILD_MEMBER_UPDATE,
    GUILD_MEMBER_CHUNK,
    GUILD_ROLE_CREATE,
    GUILD_ROLE_UPDATE,
    GUILD_ROLE_DELETE,
    GUILD_SCHEDULED_EVENT_CREATE,
    GUILD_SCHEDULED_EVENT_UPDATE,
    GUILD_SCHEDULED_EVENT_DELETE,
    GUILD_SCHEDULED_EVENT_USER_ADD,
    GUILD_SCHEDULED_EVENT_USER_REMOVE,
    INTERGRATION_CREATE,
    INTERGRATION_UPDATE,
    INTERGRATION_DELETE,
    INTERACTION_CREATE,
    INVITE_CREATE,
    INVITE_DELETE,
    MESSAGE_CREATE,
    MESSAGE_UPDATE,
    MESSAGE_DELETE,
    MESSAGE_DELETE_BULK,
    MESSAGE_REACTION_ADD,
    MESSAGE_REACTION_REMOVE,
    MESSAGE_REACTION_REMOVE_ALL,
    MESSAGE_REACTION_REMOVE_EMOJI,
    PRESENCE_UPDATE,
    STAGE_INSTANCE_CREATE,
    STAGE_INSTANCE_UPDATE,
    STAGE_INSTANCE_DELETE,
    TYPING_START,
    USER_UPDATE,
    VOICE_STATE_UPDATE,
    VOICE_SERVER_UPDATE,
    WEBHOOKS_UPDATE,

    pub fn toString(self: Event) string {
        return @tagName(self);
    }

    pub fn fromString(str: string) !Event {
        // TODO: better implementation
        // this has shit performance
        // oh also this is why this enum is all uppercase and has underscores and shit
        inline for (@typeInfo(Event).Enum.fields) |field| {
            if (std.mem.eql(u8, str, field.name)) {
                return @field(Event, field.name);
            }
        }
        return error.UnknownEvent;
    }
};

test "event enum" {
    const testing = std.testing;

    try testing.expectEqualStrings("HELLO", Event.HELLO.toString());
    try testing.expect(try Event.fromString("HELLO") == Event.HELLO);
}
