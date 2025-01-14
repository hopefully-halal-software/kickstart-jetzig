// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");
const lib = @import("../../lib/all.zig");

pub const layout = "main";

pub fn index(request: *jetzig.Request) !jetzig.View {
    const Params = struct {
        data: []const u8,
    };
    const params = try request.expectParams(Params) orelse return request.fail(.unprocessable_entity);

    const root = try request.data(.object);

    const data = try lib.security.parseValueFromEncryptedBase64(request, params.data);
    if (try lib.@"2fa".parseDataRedirectOnError(request, data)) |capture| return capture;

    try root.put("data", params.data);

    {
        const email = data.getT(.string, "email") orelse return request.fail(.internal_server_error);

        var email_sensored_buffer = try request.allocator.alloc(u8, email.len);
        std.mem.copyForwards(u8, email_sensored_buffer, email);

        var i: usize = 3;
        while (i < email_sensored_buffer.len - 5) : (i += 1) {
            email_sensored_buffer[i] = '*';
        }

        try root.put("email_sensored", email_sensored_buffer);
    }

    return request.render(.ok);
}

pub fn post(request: *jetzig.Request) !jetzig.View {
    var root = try request.data(.object);

    const Params = struct {
        data: []const u8,
        code_2fa: []const u8,
    };
    const params = try request.expectParams(Params) orelse return request.fail(.unprocessable_entity);

    const data = try lib.security.parseValueFromEncryptedBase64(request, params.data);
    if (try lib.@"2fa".parseDataRedirectOnError(request, data)) |capture| return capture;

    const expected_code = data.getT(.string, "code") orelse return request.fail(.internal_server_error);

    if (!std.mem.eql(u8, expected_code, params.code_2fa)) return request.fail(.unauthorized);

    const payload_encrypted = data.getT(.string, "payload") orelse return request.fail(.internal_server_error);
    const target_url = data.getT(.string, "target_url") orelse return request.fail(.internal_server_error);

    try root.put("payload_encrypted", payload_encrypted);
    try root.put("target_url", target_url);

    return request.render(.created);
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
