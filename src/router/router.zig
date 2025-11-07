const std = @import("std");
const db = @import("../database/database.zig");
const pg = @import("pg");
const httpz = @import("httpz");

const App = struct { db: *pg.Pool };

pub fn start(allocator: std.mem.Allocator, pool: *pg.Pool, port: ?u16) !void {
    const app = try allocator.create(App);
    app.* = App{
        .db = pool,
    };
    var server = httpz.Server(*App).init(allocator, .{
        .port = port,
    }, app) catch |err| {
        std.debug.print("\nCouldn't initialize HTTPZ server.\n{}\n", .{err});
        return err;
    };

    // Register routes immediately after creating server
    var router = try server.router(.{});
    router.get("/poop", getLineage, .{});

    std.debug.print("\nServer listening on port {?}...\n", .{port});
    try server.listen();
}

fn getLineage(app: *App, _: *httpz.Request, response: *httpz.Response) !void {
    const conn = try app.db.acquire();
    defer conn.release();
    var lineage = try conn.row("select json_agg(t) from get_lineage(2819) t", .{}) orelse {
        response.status = 500;
        response.body = "Oopsie";
        return;
    };
    defer lineage.deinit() catch {};

    const lineage_json = lineage.get([]const u8, 0);
    response.body = lineage_json;
    response.headers.add("content-type", "application/json");
}
