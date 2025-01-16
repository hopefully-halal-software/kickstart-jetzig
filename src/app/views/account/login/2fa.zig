// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");

const libs = @import("../../../lib/all.zig");

pub const layout = "main";

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.root(.object);

    const Params = struct {
        payload_encrypted: []const u8,
    };
    const params = try request.expectParams(Params) orelse return request.fail(.unprocessable_entity);

    const payload = try libs.security.parseValueFromEncryptedBase64(request, params.payload_encrypted);

    const user = payload.get("user") orelse {
        try root.put("message", "something went wrong");
        return request.render(.internal_server_error);
    };

    var session = try request.session();
    try session.put("user", user);

    return request.redirect("/account", .found);
}

test "bismi_allah_index: session's 2fa missing user" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    try app.initSession();
    var _2fa_login = try app.session.data.object();
    try _2fa_login.put("code", app.session.data.string("123456"));

    try app.session.put("2fa_login", _2fa_login);

    const response = try app.request(.GET, "/account/login/2fa", .{});
    try response.expectStatus(.found);
}

test "bismi_allah_index: session's 2fa set up correctly" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    try app.initSession();

    var user = try app.session.data.object();
    try user.put("email", app.session.data.string("ouhamouy10@gmail.com"));

    var _2fa_login = try app.session.data.object();
    try _2fa_login.put("code", app.session.data.string("123456"));
    try _2fa_login.put("user", user);

    try app.session.put("2fa_login", _2fa_login);

    const response = try app.request(.GET, "/account/login/2fa", .{});
    try response.expectStatus(.ok);
    try response.expectBodyContains("ouh************l.com");
}

test "bismi_allah_post: missings params 'code_2fa'" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    _ = try app.request(.GET, "/account/login", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    const response = try app.request(.POST, "/account/login/2fa", .{
        .params = .{
            ._jetzig_authenticity_token = token,
        },
    });

    try response.expectStatus(.unprocessable_entity);
    // try response.expectBodyContains("you need to pass arguments &#039;code_2fa&#039;");
}

test "bismi_allah_post: session has no 2fa_login object" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    try app.initSession();
    _ = try app.request(.GET, "/account/login", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    const response = try app.request(.POST, "/account/login/2fa", .{
        .params = .{
            ._jetzig_authenticity_token = token,
            .code_2fa = "wrong and alhamdo li Allah",
        },
    });

    try response.expectStatus(.found);
}

test "bismi_allah_post: wrong param 'code_2fa'" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    try app.initSession();
    _ = try app.request(.GET, "/account/login", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    var _2fa_login = try app.session.data.object();
    try _2fa_login.put("code", app.session.data.string("1a2b3c"));

    try app.session.put("2fa_login", _2fa_login);

    const response = try app.request(.POST, "/account/login/2fa", .{
        .params = .{
            ._jetzig_authenticity_token = token,
            .code_2fa = "wrong and alhamdo li Allah",
        },
    });

    try response.expectStatus(.unauthorized);
    try response.expectBodyContains("wrong 2fa code");
}

test "bismi_allah_post: correct 2fa code param, no user in session" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    try app.initSession();
    _ = try app.request(.GET, "/account/login", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    var _2fa_login = try app.session.data.object();
    try _2fa_login.put("code", app.session.data.string("1a2b3c"));

    try app.session.put("2fa_login", _2fa_login);

    const response = try app.request(.POST, "/account/login/2fa", .{
        .params = .{
            ._jetzig_authenticity_token = token,
            .code_2fa = "1a2b3c",
        },
    });

    try response.expectStatus(.internal_server_error);
    try response.expectBodyContains("something went wrong");
}

test "bismi_allah_post: correct 2fa code param and user exists in session" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    try app.initSession();
    _ = try app.request(.GET, "/account/login", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    var user = try app.session.data.object();
    try user.put("email", app.session.data.string("ouhamouy10@gmail.com"));

    var _2fa_login = try app.session.data.object();
    try _2fa_login.put("code", app.session.data.string("1a2b3c"));
    try _2fa_login.put("user", user);

    try app.session.put("2fa_login", _2fa_login);

    const response = try app.request(.POST, "/account/login/2fa", .{
        .params = .{
            ._jetzig_authenticity_token = token,
            .code_2fa = "1a2b3c",
        },
    });

    try response.expectStatus(.found);
}
