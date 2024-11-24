// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.root(.object);

    const session = try request.session();

    if (session.get("2fa_login")) |_2fa_login| {
        const user = _2fa_login.getT(.object, "user") orelse return request.redirect("/account/login", .moved_permanently);

        const email = user.getT(.string, "email") orelse return request.redirect("/account/login", .moved_permanently);

        var email_sensored_buffer = try request.allocator.alloc(u8, email.len);
        std.mem.copyForwards(u8, email_sensored_buffer, email);

        var i: usize = 3;
        while (i < email_sensored_buffer.len - 5) : (i += 1) {
            email_sensored_buffer[i] = '*';
        }

        try root.put("email_sensored", email_sensored_buffer);
    } else return request.redirect("/account/login", .moved_permanently);

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
    const _2fa_login = (session.get("2fa_login")) orelse return request.redirect("/account/login", .moved_permanently);
    const code_2fa_session = _2fa_login.getT(.string, "code") orelse return request.redirect("/account/login", .moved_permanently);

    if (!std.mem.eql(u8, code_2fa_input, code_2fa_session)) {
        try root.put("message", "wrong 2fa code");
        return request.render(.unauthorized);
    }

    const user = _2fa_login.get("user") orelse {
        try root.put("message", "something went wrong");
        return request.render(.internal_server_error);
    };

    try session.put("user", user);
    _ = try session.remove("2fa_login");

    return request.redirect("/account", .moved_permanently);
}
