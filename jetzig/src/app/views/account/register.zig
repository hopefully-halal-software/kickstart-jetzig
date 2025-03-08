// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");

const libs = @import("../../lib/all.zig");

pub const layout = "main";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    return libs.multiling.render(request, .ok, layout, "account/register/index");
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = try data.root(.object);

    const Params = struct {
        name: []const u8,
        email: []const u8,
        password: []const u8,
    };
    const params = try request.expectParams(Params) orelse {
        // return libs.errors.render(request, .unprocessable_entity, "you need to pass argument 'name', 'email' and 'password'", layout);
        return libs.errors.render(request, .unprocessable_entity, .need_to_pass_arguments_name_email_and_password, layout);
    };

    // if (try libs.db.User.existsByEmail(conn, params.email)) return libs.errors.render(request, .conflict, "email is already used by another user", layout);
    // if (try libs.db.User.existsBy(request, .{ .email = params.email })) return libs.errors.render(request, .conflict, .email_already_used, layout);
    if (null != try request.repo.execute(jetzig.database.Query(.User).findBy(.{ .email = params.email }))) return libs.errors.render(request, .conflict, .email_already_used, layout);

    var user = try data.object();
    try user.put("name", data.string(params.name));
    try user.put("email", data.string(params.email));
    try user.put("password", data.string(params.password));

    var payload = try data.object();
    try payload.put("user", user);

    return libs.@"2fa".redirect2fa(request, params.email, 5, .register, payload, .{ .subject = "register", .to = &.{.{ .email = params.email }} });
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
}
