// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");
const libs = @import("../../lib/all.zig");

pub const layout = "main";

pub fn index(request: *jetzig.Request) !jetzig.View {
    return libs.multiling.render(request, .ok, layout, "account/recovery/index");
}

pub fn post(request: *jetzig.Request) !jetzig.View {
    _ = try request.data(.object);

    const Params = struct {
        email: []const u8,
        password: []const u8,
    };
    // const params = try request.expectParams(Params) orelse return libs.errors.render(request, .unprocessable_entity, "you need to pass argument 'email'", layout);
    const params = try request.expectParams(Params) orelse return libs.errors.render(request, .unprocessable_entity, .need_to_pass_argument_email, layout);

    if (null == try request.repo.execute(jetzig.database.Query(.User).findBy(.{ .email = params.email }))) return libs.errors.render(request, .unauthorized, .email_does_no_exist, layout);

    var payload = try request.response_data.object();
    try payload.put("email", params.email);
    try payload.put("password", params.password);

    return libs.@"2fa".redirect2fa(request, params.email, 5, "/account/recovery/2fa", payload, .{ .subject = "recovery", .to = &.{params.email} });
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
