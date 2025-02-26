// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");

pub const formats: jetzig.Route.Formats = .{
    .index = &.{.json},
};

pub fn index(request: *jetzig.Request) !jetzig.View {
    var root = try request.data(.object);

    try root.put("name", jetzig.authenticity_token_name);
    try root.put("value", try request.authenticityToken());

    return request.render(.ok);
}

test "get" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/api/v1/auth/tokens/ant-csrf.json", .{});
    try response.expectStatus(.ok);
}
