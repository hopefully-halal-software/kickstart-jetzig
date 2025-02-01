// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");
const libs = @import("../../lib/all.zig");

pub const layout = "main";

pub fn index(request: *jetzig.Request) !jetzig.View {
    const Params = struct {
        data: []const u8,
    };
    const params = try request.expectParams(Params) orelse return libs.errors.render(request, .unprocessable_entity, .need_to_pass_arguments, layout);

    const root = try request.data(.object);

    const data = try libs.security.parseValueFromEncryptedBase64(request, params.data);
    if (try libs.@"2fa".parseDataRenderOnError(request, data, layout)) |capture| return capture;

    try root.put("data", params.data);

    {
        const email = data.getT(.string, "email") orelse return libs.errors.render(request, .internal_server_error, .internal_error, layout);

        var email_sensored_buffer = try request.allocator.alloc(u8, email.len);
        std.mem.copyForwards(u8, email_sensored_buffer, email);

        var i: usize = 3;
        while (i < email_sensored_buffer.len - 5) : (i += 1) {
            email_sensored_buffer[i] = '*';
        }

        try root.put("email_sensored", email_sensored_buffer);
    }

    return libs.multiling.render(request, .ok, layout, "utils/2fa/index");
}

pub fn post(request: *jetzig.Request) !jetzig.View {
    var root = try request.data(.object);

    const Params = struct {
        data: []const u8,
        code_2fa: []const u8,
    };
    const params = try request.expectParams(Params) orelse return libs.errors.render(request, .unprocessable_entity, .need_to_pass_arguments, layout);

    const data = try libs.security.parseValueFromEncryptedBase64(request, params.data);
    if (try libs.@"2fa".parseDataRenderOnError(request, data, layout)) |capture| return capture;

    const expected_code = data.getT(.string, "code") orelse return libs.errors.render(request, .internal_server_error, .internal_error, layout);

    if (!std.mem.eql(u8, expected_code, params.code_2fa)) return libs.errors.render(request, .unauthorized, .incorrect_params, layout);

    const payload_encrypted = data.getT(.string, "payload") orelse return libs.errors.render(request, .internal_server_error, .internal_error, layout);
    const target_url = data.getT(.string, "target_url") orelse return libs.errors.render(request, .internal_server_error, .internal_error, layout);

    try root.put("payload_encrypted", payload_encrypted);
    try root.put("target_url", target_url);

    return libs.multiling.render(request, .created, layout, "utils/2fa/post");
}

test "index" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/utils/2fa", .{});
    try response.expectStatus(.ok);
}

test "post" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.POST, "/utils/2fa", .{});
    try response.expectStatus(.created);
}
