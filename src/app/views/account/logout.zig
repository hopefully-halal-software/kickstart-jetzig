// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");

pub fn post(request: *jetzig.Request) !jetzig.View {
    const session = try request.session();
    try session.reset();
    return request.redirect("/account/login", .found);
}

test "post" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.POST, "/account/logout", .{});
    try response.expectStatus(.created);
}
