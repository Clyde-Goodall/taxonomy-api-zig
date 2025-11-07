const std = @import("std");
const pg = @import("pg");

pub fn buildPool(allocator: std.mem.Allocator, connection_string: []const u8) !*pg.Pool {
    const uri = try std.Uri.parse(connection_string);
    return pg.Pool.initUri(allocator, uri, .{
        .size = 5,
        .timeout = 10_000,
    }) catch |err| {
        std.debug.print("\nUnable to initialize pg pool. error: {}\n", .{err});
        return err;
    };
}
