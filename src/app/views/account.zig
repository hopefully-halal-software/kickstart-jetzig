// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");
const lib = @import("../lib/all.zig");

pub const layout = "main";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.root(.object);
    const session = try request.session();

    // if the user is not logged in
    // redirect them to "/account/login"
    const user = if (session.get("user")) |user_capture| user_capture else return request.redirect("/account/login", .found);

    try root.put("user", user);

    return request.render(.ok);
}

test "bismi_allah_index: not logged in" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/account", .{});
    try response.expectStatus(.found);
    // try response.expectRedirect("/account/login");
}

test "bismi_allah_index: is logged in" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    try lib.tests.login(&app);

    const response = try app.request(.GET, "/account", .{});
    try response.expectStatus(.ok);
    try response.expectBodyContains("1");
    try response.expectBodyContains("bismi_allah_user");
    try response.expectBodyContains("ouhamouy10@gmail.com");
}
