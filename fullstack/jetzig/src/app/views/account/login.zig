// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");
const libs = @import("../../lib/all.zig");

// pub const formats: jetzig.Route.Formats = .{
//     .post = &.{.json},
// };

pub fn post(request: *jetzig.Request) !jetzig.View {
    _ = try request.data(.object);

    const Params = struct {
        email: []const u8,
        password: []const u8,
    };
    const params = try request.expectParams(Params) orelse return libs.render(request, .unprocessable_entity, "need to pass 'email' and 'password'");

    const user = get_user: {
        const query = jetzig.database.Query(.User).findBy(.{ .email = params.email });

        const user = try request.repo.execute(query) orelse return libs.render(request, .unauthorized, "incorrect email or password");

        // check_password
        {
            var buff_in: [libs.security.max_password_size + libs.security.password_salt_length]u8 = undefined;
            std.mem.copyForwards(u8, buff_in[0..params.password.len], params.password);
            std.mem.copyForwards(u8, buff_in[params.password.len..], user.password_salt);

            var buff_out: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
            std.crypto.hash.sha2.Sha256.hash(buff_in[0 .. params.password.len + libs.security.password_salt_length], &buff_out, .{});

            const buff_password_hash_hex: [64]u8 = std.fmt.bytesToHex(buff_out, .lower);

            if (!std.mem.eql(u8, user.password_hash, &buff_password_hash_hex)) {
                return libs.render(request, .unauthorized, "incorrect email or password");
            }
        }

        break :get_user .{
            .id = user.id,
            .name = user.name,
            .email = user.email,
            .created_at = user.created_at,
        };
    };

    var payload = try request.response_data.object();
    try payload.put("user", user);

    // return libs.@"2fa".redirect2fa(request, params.email, 5, "/api/v1/auth/account/login/2fa", payload, .{ .subject = "login", .to = &.{params.email} });
    return libs.@"2fa".redirect2fa(request, params.email, 5, libs.actions.Actions.login, payload, .{ .subject = "login", .to = &.{params.email} });
}

test "post" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.POST, "/api/v1/auth/account/login", .{});
    try response.expectStatus(.created);
}
