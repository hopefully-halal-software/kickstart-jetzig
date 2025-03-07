// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");

const libs = @import("all.zig");

pub const Actions = enum {
    login,
    register,
    recover_account,
};

pub fn stringToAction(action_name: []const u8) ?Actions {
    const actions = @typeInfo(Actions).@"enum";
    inline for (actions.fields) |field| {
        if (std.mem.eql(u8, action_name, field.name)) return @enumFromInt(field.value);
    }
    return null;
}

pub fn call(request: *jetzig.Request, action_name: []const u8, payload_raw: []const u8) !jetzig.View {
    const action = stringToAction(action_name) orelse return error.ActionNotSupported;
    const payload = try libs.security.parseValueFromEncryptedBase64(request, payload_raw);

    return switch (action) {
        .login => login(request, payload),
        .register => register(request, payload),
        .recover_account => recover_account(request, payload),
    };
}

pub fn login(request: *jetzig.Request, payload: *jetzig.Data.Value) !jetzig.View {
    // const user = payload.get("user") orelse return libs.errors.render(request, .internal_server_error, "something went wrong", layout);
    const user = payload.get("user") orelse return libs.render(request, .internal_server_error, "something went wrong");

    var session = try request.session();
    try session.put("user", user);

    var root = try request.data(.object);
    try root.put("path", "/account");
    return request.render(.ok);
}

pub fn register(request: *jetzig.Request, payload: *jetzig.Data.Value) !jetzig.View {
    // const user = payload.get("user") orelse return libs.errors.render(request, .internal_server_error, "something went wrong", layout);
    const user = payload.get("user") orelse return libs.render(request, .internal_server_error, "something went wrong");

    // insert user
    {
        const name = user.getT(.string, "name") orelse return libs.render(request, .internal_server_error, "internal error");
        const email = user.getT(.string, "email") orelse return libs.render(request, .internal_server_error, "internal error");
        const password = user.getT(.string, "password") orelse return libs.render(request, .internal_server_error, "internal error");

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

    var root = try request.data(.object);
    try root.put("path", "/account/login");
    return request.render(.ok);
}

pub fn recover_account(request: *jetzig.Request, payload: *jetzig.Data.Value) !jetzig.View {
    // set password
    {
        // const email = payload.getT(.string, "email") orelse return libs.errors.render(request, .internal_server_error, "something went wrong", layout);
        // const password = payload.getT(.string, "password") orelse return libs.errors.render(request, .internal_server_error, "something went wrong", layout);
        const email = payload.getT(.string, "email") orelse return libs.render(request, .internal_server_error, "something went wrong");
        const password = payload.getT(.string, "password") orelse return libs.render(request, .internal_server_error, "something went wrong");

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
            .update(.{
            .password_hash = &password_hash,
            .password_salt = &password_salt,
        }).where(.{ .email = email });
        try request.repo.execute(query);
    }

    var root = try request.data(.object);
    try root.put("path", "/account/login");
    return request.render(.ok);
}
