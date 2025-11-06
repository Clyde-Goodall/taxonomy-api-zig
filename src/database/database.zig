const std = @import("std");
const pg = @import("pg");

pub const Connection = struct {
    pool: *pg.Pool,
    connection: *pg.Conn,
    allocator: std.mem.Allocator,

    pub fn init(
        allocator: std.mem.Allocator,
        connection_string: []const u8,
    ) !Connection {
        const uri = try std.Uri.parse(connection_string);
        const pool = try pg.Pool.initUri(allocator, uri, .{
            .size = 5,
            .timeout = 10_000,
        });
        const conn = try pool.acquire();

        return Connection{
            .pool = pool,
            .connection = conn,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Connection) void {
        self.pool.release(self.connection);
        defer self.pool.deinit();
    }
};
