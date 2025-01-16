// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");

const libs = @import("../../lib/all.zig");

pub const layout = "main";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    return request.render(.ok);
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.root(.object);

    const Params = struct {
        name: []const u8,
        email: []const u8,
        password: []const u8,
    };
    const params = try request.expectParams(Params) orelse {
        try root.put("message", data.string("you need to pass argument 'name', 'email' and 'password'"));
        return request.fail(.unprocessable_entity);
    };

    var conn = try libs.db.acquire(request);
    defer conn.release();

    if (try libs.db.User.existsByEmail(conn, params.email)) {
        try root.put("message", data.string("email is already used by another user"));
        return request.render(.conflict);
    }

    var user = try data.object();
    try user.put("name", data.string(params.name));
    try user.put("email", data.string(params.email));
    try user.put("password", data.string(params.password));

    var payload = try data.object();
    try payload.put("user", user);

    return libs.@"2fa".redirect2fa(request, params.email, 5, "/account/register/2fa", payload, .{ .subject = "register", .to = &.{params.email} });
}

test "bismi_allah_index" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/account/register", .{});
    try response.expectStatus(.ok);
}

test "bismi_allah_post: without required params" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();
    // to set anti_csrf token
    _ = try app.request(.GET, "/account/register", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    const response = try app.request(.POST, "/account/register", .{
        .params = .{ ._jetzig_authenticity_token = token },
    });
    try response.expectStatus(.unprocessable_entity);
}

test "bismi_allah_post: with required params (already present)" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();
    // to set anti_csrf token
    _ = try app.request(.GET, "/account/register", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    const response = try app.request(.POST, "/account/register", .{
        .params = .{
            ._jetzig_authenticity_token = token,
            .name = "bismi_allah_username",
            .email = "ouhamouy10@gmail.com",
            .password = "bismi_allah",
        },
    });
    // incha2Allah will be changed to use .unprocessable_entity
    try response.expectStatus(.conflict);
    try response.expectBodyContains("email is already used by another user");
    try std.testing.expectEqual(null, app.session.get("2fa_register"));
}

test "bismi_allah_post: with required params (correct info)" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();
    // to set anti_csrf token
    _ = try app.request(.GET, "/account/register", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    const response = try app.request(.POST, "/account/register", .{
        .params = .{
            ._jetzig_authenticity_token = token,
            .name = "bismi_allah_usernam2",
            .email = "ouhamouy12@gmail.com",
            .password = "bismi_allah",
        },
    });
    try response.expectStatus(.found);
    try std.testing.expect(null != app.session.get("2fa_register"));
}
