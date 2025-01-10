// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");
const db = @import("../../lib/db.zig");

pub const layout = "main";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    return request.render(.ok);
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.root(.object);

    const Params = struct {
        email: []const u8,
        password: []const u8,
    };
    const params = try request.expectParams(Params) orelse {
        try root.put("message", data.string("you need to pass arguments 'email' and 'password'"));
        return request.fail(.unprocessable_entity);
    };

    var conn = try db.acquire(request);
    defer conn.release();

    const user = db.User.getAuth(conn, params.email, params.password, data) catch |err| switch (err) {
        db.User.Error.WrongEmail, db.User.Error.WrongPassword => {
            try root.put("message", data.string("email or password were incorrect"));
            return request.render(.unauthorized);
        },
        else => return err,
    };

    var code_2fa_buffer: [3]u8 = undefined;
    std.crypto.random.bytes(&code_2fa_buffer);
    // const code_2fa = std.fmt.bytesToHex(code_2fa_buffer, .lower);
    // try data.string(code_2fa)
    const code_2fa = data.string(&std.fmt.bytesToHex(code_2fa_buffer, .lower));

    const session = try request.session();

    var session_2fa_login = try data.object();
    try session_2fa_login.put("user", user);
    try session_2fa_login.put("code", code_2fa);
    try session.put("2fa_login", session_2fa_login);

    try root.put("code_2fa", code_2fa);

    const mailer = request.mail("2fa", .{ .subject = "idz: email verification for login", .to = &.{params.email} });
    try mailer.deliver(.background, .{});

    return request.redirect("/account/login/2fa", .found);

    // try root.put("message", "alhamdo li Allah cerdintials were correct<br>now you will -incha2Allah- be redirected to confirm 2fa code");
    // return request.render(.created);
}

test "bismi_allah_index" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/account/login", .{});
    try response.expectStatus(.ok);
}

test "bismi_allah_post: without required params" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();
    // to set anti_csrf token
    _ = try app.request(.GET, "/account/login", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    const response = try app.request(.POST, "/account/login", .{
        .params = .{ ._jetzig_authenticity_token = token },
    });
    try response.expectStatus(.unprocessable_entity);
}

test "bismi_allah_post: with required params (wrong info)" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();
    // to set anti_csrf token
    _ = try app.request(.GET, "/account/login", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    const response = try app.request(.POST, "/account/login", .{
        .params = .{
            ._jetzig_authenticity_token = token,
            .email = "wrongmail@bismi_allah.com",
            .password = "wrong_password",
        },
    });
    // incha2Allah will be changed to use .unprocessable_entity
    try response.expectStatus(.unauthorized);
    try response.expectBodyContains("email or password were incorrect");
    try std.testing.expectEqual(null, app.session.get("2fa_login"));
}

test "bismi_allah_post: with required params (correct info)" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();
    // to set anti_csrf token
    _ = try app.request(.GET, "/account/login", .{});

    const token = app.session.getT(.string, jetzig.authenticity_token_name).?;

    const response = try app.request(.POST, "/account/login", .{
        .params = .{
            ._jetzig_authenticity_token = token,
            .email = "ouhamouy10@gmail.com",
            .password = "bismi_allah",
        },
    });
    try response.expectStatus(.found);
    try std.testing.expect(null != app.session.get("2fa_login"));
}
