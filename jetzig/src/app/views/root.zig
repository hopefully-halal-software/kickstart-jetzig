// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");
const libs = @import("../lib/all.zig");

pub const layout = "main";

pub fn index(request: *jetzig.Request) !jetzig.View {
    return libs.multiling.render(request, .ok, layout, "root/index");
}

// bismi Allah
// only Allah knows how I am gonna test it
test "bismi_allah_index" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/", .{});
    try response.expectStatus(.ok);
}
