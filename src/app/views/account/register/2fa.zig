// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");
const db = @import("../../../lib/db.zig");

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.root(.object);

    const session = try request.session();

    if (try session.get("2fa_register")) |_2fa_register| {
        const user = _2fa_register.getT(.object, "user") orelse return request.redirect("/account/register", .moved_permanently);

        const email = user.getT(.string, "email") orelse return request.redirect("/account/register", .moved_permanently);

        var email_sensored_buffer = try request.allocator.alloc(u8, email.len);
        std.mem.copyForwards(u8, email_sensored_buffer, email);

        var i: usize = 3;
        while (i < email_sensored_buffer.len - 5) : (i += 1) {
            email_sensored_buffer[i] = '*';
        }

        try root.put("email_sensored", email_sensored_buffer);
    } else return request.redirect("/account/register", .moved_permanently);

    return request.render(.ok);
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.root(.object);

    const params = try request.params();
    const code_2fa_input = params.getT(.string, "code_2fa") orelse {
        try root.put("message", data.string("you need to pass arguments 'code_2fa'"));
        return request.render(.bad_request);
    };

    const session = try request.session();
    const _2fa_register = (try session.get("2fa_register")) orelse return request.redirect("/account/register", .moved_permanently);
    const code_2fa_session = _2fa_register.getT(.string, "code") orelse return request.redirect("/account/register", .moved_permanently);

    if (!std.mem.eql(u8, code_2fa_input, code_2fa_session)) {
        try root.put("message", "wrong 2fa code");
        return request.render(.unauthorized);
    }

    const user = _2fa_register.getT(.object, "user") orelse {
        try root.put("message", "something went wrong");
        return request.render(.internal_server_error);
    };

    _ = try session.remove("2fa_register");

    var conn = try request.global.pool.acquire();
    defer conn.release();

    try db.User.insertUser(
        conn,
        user.getT(.string, "login") orelse {
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
    );

    return request.redirect("/account/login", .moved_permanently);
}
