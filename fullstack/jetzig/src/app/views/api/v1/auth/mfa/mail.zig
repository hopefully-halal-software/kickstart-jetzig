// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");
const libs = @import("../../../../../lib/all.zig");

pub const formats: jetzig.Route.Formats = .{
    .post = &.{.json},
};

pub fn post(request: *jetzig.Request) !jetzig.View {
    const Params = struct {
        data: []const u8,
        code_2fa: []const u8,
    };
    const params = try request.expectParams(Params) orelse return libs.render(request, .unprocessable_entity, "need to pass arguments (data, code_2fa)");

    const data = try libs.security.parseValueFromEncryptedBase64(request, params.data);
    if (try libs.@"2fa".parseDataRenderOnError(request, data)) |capture| return capture;

    const expected_code = data.getT(.string, "code") orelse return libs.render(request, .internal_server_error, "internal error");

    if (!std.mem.eql(u8, expected_code, params.code_2fa)) return libs.render(request, .unauthorized, "incorrect params (code 2fa)");

    const payload_encrypted = data.getT(.string, "payload") orelse return libs.render(request, .internal_server_error, "internal error");
    const action = data.getT(.string, "action") orelse return libs.render(request, .internal_server_error, "internal error");

    return libs.actions.call(request, action, payload_encrypted);
}

test "post" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.POST, "/api/v1/auth/mfa/mail", .{});
    try response.expectStatus(.created);
}
