// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");
const db = @import("../../../lib/db.zig");
const tests = @import("../../../lib/tests.zig");

pub const layout = "main";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.root(.object);

    const session = try request.session();

    if (session.get("2fa_register")) |_2fa_register| {
        const user = _2fa_register.getT(.object, "user") orelse return request.redirect("/account/register", .found);

        const email = user.getT(.string, "email") orelse return request.redirect("/account/register", .found);

        var email_sensored_buffer = try request.allocator.alloc(u8, email.len);
        std.mem.copyForwards(u8, email_sensored_buffer, email);

        var i: usize = 3;
        while (i < email_sensored_buffer.len - 5) : (i += 1) {
            email_sensored_buffer[i] = '*';
        }

        try root.put("email_sensored", email_sensored_buffer);
    } else return request.redirect("/account/register", .found);

    return request.render(.ok);
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.root(.object);

    const Params = struct {
        code_2fa: []const u8,
    };
    const params = try request.expectParams(Params) orelse {
        try root.put("message", data.string("you need to pass argument 'code_2fa'"));
        return request.fail(.unprocessable_entity);
    };

    const session = try request.session();
    const _2fa_register = (session.get("2fa_register")) orelse return request.redirect("/account/register", .found);
    const code_2fa_session = _2fa_register.getT(.string, "code") orelse return request.redirect("/account/register", .found);

    if (!std.mem.eql(u8, params.code_2fa, code_2fa_session)) {
        try root.put("message", "wrong 2fa code");
        return request.render(.unauthorized);
    }

    const user = _2fa_register.getT(.object, "user") orelse {
        try root.put("message", "something went wrong");
        return request.render(.internal_server_error);
    };

    _ = try session.remove("2fa_register");

    var conn = try db.acquire(request);
    defer conn.release();

    db.User.insertUser(
        conn,
        user.getT(.string, "name") orelse {
            try root.put("message", "internal error");
            return request.render(.internal_server_error);
        },
        user.getT(.string, "email") orelse {
            try root.put("message", "internal error");
            return request.render(.internal_server_error);
        },
        user.getT(.string, "password") orelse {
            try root.put("message", "internal error");
            return request.render(.internal_server_error);
        },
    ) catch |err| {
        std.debug.print("alhamdo li Allah err: '{any}'\n", .{err});
        if (conn.err) |pge| std.log.err("alhamdo li Allah error: {s}\n", .{pge.message});
        try root.put("message", "internal error");
        return request.render(.internal_server_error);
    };

    return request.redirect("/account/login", .found);
}

test "bismi_allah_index: session's 2fa missing user" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    try app.initSession();
    var _2fa_register = try app.session.data.object();
    try _2fa_register.put("code", app.session.data.string("123456"));

    try app.session.put("2fa_register", _2fa_register);

    const response = try app.request(.GET, "/account/register/2fa", .{});
    try response.expectStatus(.found);
}

test "bismi_allah_index: session's 2fa set up correctly" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    try app.initSession();

    var user = try app.session.data.object();
    try user.put("email", app.session.data.string("ouhamouy10@gmail.com"));

    var _2fa_register = try app.session.data.object();
    try _2fa_register.put("code", app.session.data.string("123456"));
    try _2fa_register.put("user", user);

    try app.session.put("2fa_register", _2fa_register);

    const response = try app.request(.GET, "/account/register/2fa", .{});
    try response.expectStatus(.ok);
    try response.expectBodyContains("ouh************l.com");
}

test "bismi_allah_post: missings params 'code_2fa'" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    _ = try app.request(.GET, "/account/register", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    const response = try app.request(.POST, "/account/register/2fa", .{
        .params = .{
            ._jetzig_authenticity_token = token,
        },
    });

    try response.expectStatus(.unprocessable_entity);
    // try response.expectBodyContains("you need to pass arguments &#039;code_2fa&#039;");
}

test "bismi_allah_post: session has no 2fa_register object" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    try app.initSession();
    _ = try app.request(.GET, "/account/register", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    const response = try app.request(.POST, "/account/register/2fa", .{
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
    _ = try app.request(.GET, "/account/register", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    var _2fa_register = try app.session.data.object();
    try _2fa_register.put("code", app.session.data.string("1a2b3c"));

    try app.session.put("2fa_register", _2fa_register);

    const response = try app.request(.POST, "/account/register/2fa", .{
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
    _ = try app.request(.GET, "/account/register", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    var _2fa_register = try app.session.data.object();
    try _2fa_register.put("code", app.session.data.string("1a2b3c"));

    try app.session.put("2fa_register", _2fa_register);

    const response = try app.request(.POST, "/account/register/2fa", .{
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
    _ = try app.request(.GET, "/account/register", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    var user = try app.session.data.object();
    try user.put("name", app.session.data.string("bismi_allah_user_test"));
    try user.put("email", app.session.data.string("ouhamouy12@gmail.com"));
    try user.put("password", app.session.data.string("bismi_allah"));

    var _2fa_register = try app.session.data.object();
    try _2fa_register.put("code", app.session.data.string("1a2b3c"));
    try _2fa_register.put("user", user);

    try app.session.put("2fa_register", _2fa_register);

    const response = try app.request(.POST, "/account/register/2fa", .{
        .params = .{
            ._jetzig_authenticity_token = token,
            .code_2fa = "1a2b3c",
        },
    });

    try response.expectStatus(.found);
}

test "bismi_allah_post: too long user info" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    try app.initSession();
    _ = try app.request(.GET, "/account/register", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    var user = try app.session.data.object();
    try user.put("name", app.session.data.string("bismi_allah_user_looooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong"));
    try user.put("email", app.session.data.string("ouhamoooooooooooooooooooooouy10@gmail.com"));
    try user.put("password", app.session.data.string("bismi_allah_loooooooooooooooooooooooooooooooooooooooooooooooooong"));

    var _2fa_register = try app.session.data.object();
    try _2fa_register.put("code", app.session.data.string("1a2b3c"));
    try _2fa_register.put("user", user);

    try app.session.put("2fa_register", _2fa_register);

    const response = try app.request(.POST, "/account/register/2fa", .{
        .params = .{
            ._jetzig_authenticity_token = token,
            .code_2fa = "1a2b3c",
        },
    });

    try response.expectStatus(.internal_server_error);
    try response.expectBodyContains("internal error");
}
