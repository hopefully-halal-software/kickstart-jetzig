// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");
const db = @import("../../lib/db.zig");

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    return request.render(.ok);
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.root(.object);

    const params = try request.params();

    const login = params.getT(.string, "login") orelse {
        try root.put("message", data.string("you need to pass arguments 'login'"));
        return request.render(.bad_request);
    };
    const email = params.getT(.string, "email") orelse {
        try root.put("message", data.string("you need to pass arguments 'email'"));
        return request.render(.bad_request);
    };
    const password = params.getT(.string, "password") orelse {
        try root.put("message", data.string("you need to pass arguments 'password'"));
        return request.render(.bad_request);
    };

    var conn = try request.global.pool.acquire();
    defer conn.release();

    const user = db.User.getAuth(conn, login, password, email, data) catch |err| switch (err) {
        db.User.Error.WrongLogin, db.User.Error.WrongEmail, db.User.Error.WrongPassword => {
            try root.put("message", data.string("login, email or password were incorrect"));
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

    const mailer = request.mail("2fa", .{ .subject = "email verification for login", .to = &.{email} });
    try mailer.deliver(.background, .{});

    return request.redirect("/account/login/2fa", .moved_permanently);

    // try root.put("message", "alhamdo li Allah cerdintials were correct<br>now you will -incha2Allah- be redirected to confirm 2fa code");
    // return request.render(.created);
}
