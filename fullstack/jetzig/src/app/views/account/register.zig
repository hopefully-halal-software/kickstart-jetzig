// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");

const libs = @import("../../lib/all.zig");

// pub const formats: jetzig.Route.Formats = .{
//     .post = &.{.json},
// };

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = try data.root(.object);

    const Params = struct {
        name: []const u8,
        email: []const u8,
        password: []const u8,
    };
    const params = try request.expectParams(Params) orelse return libs.render(request, .unprocessable_entity, "need to pass argument 'name', 'email' and 'password'");

    if (null != try request.repo.execute(jetzig.database.Query(.User).findBy(.{ .email = params.email }))) return libs.render(request, .conflict, "email already used");

    var user = try data.object();
    try user.put("name", data.string(params.name));
    try user.put("email", data.string(params.email));
    try user.put("password", data.string(params.password));

    var payload = try data.object();
    try payload.put("user", user);

    // return libs.@"2fa".redirect2fa(request, params.email, 5, "/api/v1/auth/account/register/2fa", payload, .{ .subject = "login", .to = &.{params.email} });
    return libs.@"2fa".redirect2fa(request, params.email, 5, libs.actions.Actions.register, payload, .{ .subject = "register", .to = &.{params.email} });
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
