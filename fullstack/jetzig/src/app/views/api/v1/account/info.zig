// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");
const libs = @import("../../../../lib/all.zig");

pub const formats: jetzig.Route.Formats = .{
    .index = &.{.json},
};

pub fn index(request: *jetzig.Request) !jetzig.View {
    var root = try request.data(.object);

    const session = try request.session();
    const user = session.get("user") orelse return libs.render(request, .unauthorized, "not logged in");

    try root.put("user", user);

    return request.render(.ok);
}

test "get" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/api/v1/auth/account/info", .{});
    try response.expectStatus(.ok);
}
