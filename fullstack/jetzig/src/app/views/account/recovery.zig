// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");
const libs = @import("../../lib/all.zig");

pub fn post(request: *jetzig.Request) !jetzig.View {
    _ = try request.data(.object);

    const Params = struct {
        email: []const u8,
        password: []const u8,
    };
    // const params = try request.expectParams(Params) orelse return libs.errors.render(request, .unprocessable_entity, "you need to pass argument 'email'", layout);
    const params = try request.expectParams(Params) orelse return libs.render(request, .unprocessable_entity, "need to pass argument: email");

    if (null == try request.repo.execute(jetzig.database.Query(.User).findBy(.{ .email = params.email }))) return libs.render(request, .unauthorized, "email does not exist");

    var payload = try request.response_data.object();
    try payload.put("email", params.email);
    try payload.put("password", params.password);

    return libs.@"2fa".redirect2fa(request, params.email, 5, .recover_account, payload, .{ .subject = "recovery", .to = &.{params.email} });
}

test "index" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/account/recovery", .{});
    try response.expectStatus(.ok);
}

test "post" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.POST, "/account/recovery", .{});
    try response.expectStatus(.created);
}
