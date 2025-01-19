// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");
const libs = @import("../../lib/all.zig");

pub const layout = "main";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    return libs.multiling.render(request, .ok, layout, "account/login/index");
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = try data.root(.object);

    const Params = struct {
        email: []const u8,
        password: []const u8,
    };
    // const params = try request.expectParams(Params) orelse return libs.errors.render(request, .unprocessable_entity, "you need to pass argument 'name' and 'password'", layout);
    const params = try request.expectParams(Params) orelse return libs.errors.render(request, .unprocessable_entity, .need_to_pass_arguments_name_and_password, layout);

    var conn = try libs.db.acquire(request);
    defer conn.release();

    const user = libs.db.User.getAuth(conn, params.email, params.password, data) catch |err| switch (err) {
        libs.db.User.Error.WrongEmail, libs.db.User.Error.WrongPassword => {
            // return libs.errors.render(request, .unauthorized, "email or password were incorrect", layout);
            return libs.errors.render(request, .unauthorized, .incorrect_email_or_password, layout);
        },
        else => return err,
    };

    var payload = try data.object();
    try payload.put("user", user);

    return libs.@"2fa".redirect2fa(request, params.email, 5, "/account/login/2fa", payload, .{ .subject = "login", .to = &.{params.email} });
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
}
