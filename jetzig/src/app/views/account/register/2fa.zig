// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");

const libs = @import("../../../lib/all.zig");

pub const layout = "main";

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = try data.root(.object);

    const Params = struct {
        payload_encrypted: []const u8,
    };
    const params = try request.expectParams(Params) orelse return libs.errors.render(request, .unprocessable_entity, .need_to_pass_arguments, layout);

    const payload = try libs.security.parseValueFromEncryptedBase64(request, params.payload_encrypted);

    const user = payload.get("user") orelse {
        // return libs.errors.render(request, .internal_server_error, "something went wrong", layout);
        return libs.errors.render(request, .internal_server_error, .something_went_wrong, layout);
    };

    // insert user
    {
        const name = user.getT(.string, "name") orelse return libs.errors.render(request, .internal_server_error, .internal_error, layout);
        const email = user.getT(.string, "email") orelse return libs.errors.render(request, .internal_server_error, .internal_error, layout);
        const password = user.getT(.string, "password") orelse return libs.errors.render(request, .internal_server_error, .internal_error, layout);

        var password_salt: [12]u8 = undefined;
        var password_hash: [64]u8 = undefined;
        // generate password salt
        {
            var password_salt_raw: [6]u8 = undefined;
            std.crypto.random.bytes(&password_salt_raw);
            password_salt = std.fmt.bytesToHex(&password_salt_raw, .lower);
        }
        // generate password hash
        {
            var password_and_salt_buffer: [libs.security.max_password_size + libs.security.password_salt_length]u8 = undefined;
            std.mem.copyForwards(u8, password_and_salt_buffer[0..password.len], password);
            std.mem.copyForwards(u8, password_and_salt_buffer[password.len..], &password_salt);

            var password_hash_raw: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
            std.crypto.hash.sha2.Sha256.hash(password_and_salt_buffer[0 .. password.len + libs.security.password_salt_length], &password_hash_raw, .{});
            password_hash = std.fmt.bytesToHex(password_hash_raw, .lower);
        }

        const query = jetzig.database.Query(.User)
            .insert(.{
            .name = name,
            .email = email,
            .password_hash = &password_hash,
            .password_salt = &password_salt,
        });
        try request.repo.execute(query);
    }

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
