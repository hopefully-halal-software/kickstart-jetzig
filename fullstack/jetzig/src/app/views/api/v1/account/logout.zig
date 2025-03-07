// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");
const tests = @import("../../../../lib/tests.zig");

pub const formats: jetzig.Route.Formats = .{
    .post = &.{.json},
};

pub fn post(request: *jetzig.Request) !jetzig.View {
    const session = try request.session();
    try session.reset();
    return request.render(.ok);
}

test "bismi_allah_post: no csrf" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    // need that for setting the csrf token thanks to Allah
    _ = try app.request(.GET, "/account/login", .{});

    try tests.login(&app);

    const response = try app.request(.POST, "/account/logout", .{});

    try std.testing.expect(!try app.session.remove("user"));

    try response.expectStatus(.forbidden);
}

test "bismi_allah_post: with csrf" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    // need that for setting the csrf token thanks to Allah
    _ = try app.request(.GET, "/account/login", .{});

    try tests.login(&app);

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    const response = try app.request(
        .POST,
        "/account/logout",
        .{ .params = .{ ._jetzig_authenticity_token = token } },
    );

    try std.testing.expect(!try app.session.remove("user"));

    try response.expectStatus(.found);
}
