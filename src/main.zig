const std = @import("std");
const dotenv = @import("dotenv");
const database = @import("database/database.zig");
const pg = @import("pg");
const router = @import("router/router.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var env = try dotenv.init(allocator, ".env");
    defer env.deinit();

    const pg_connection_string = env.get("PG_CONNECTION_STRING") orelse {
        std.log.err("PG_CONNECTION_STRING environment variable not set", .{});
        return error.MissingEnvironmentVariable;
    };
    const port = try std.fmt.parseInt(u16, env.get("PORT") orelse "3000", 10);

    var db = try database.buildPool(allocator, pg_connection_string);
    defer db.deinit();

    try router.start(allocator, db, port);
}
