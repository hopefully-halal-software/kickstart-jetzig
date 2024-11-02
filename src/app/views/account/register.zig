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

    if (try db.User.exists(conn, login)) {
        try root.put("message", data.string("login is already used by another user"));
        std.debug.print("alhamdo li Allah used login already exists\n", .{});
        return request.render(.conflict);
    }

    var code_2fa_buffer: [3]u8 = undefined;
    std.crypto.random.bytes(&code_2fa_buffer);
    // const code_2fa = std.fmt.bytesToHex(code_2fa_buffer, .lower);
    // try data.string(code_2fa)
    const code_2fa = data.string(&std.fmt.bytesToHex(code_2fa_buffer, .lower));

    const session = try request.session();

    var user = try data.object();
    try user.put("login", data.string(login));
    try user.put("email", data.string(email));
    try user.put("password", data.string(password));

    var session_2fa_register = try data.object();
    try session_2fa_register.put("user", user);
    try session_2fa_register.put("code", code_2fa);
    try session.put("2fa_register", session_2fa_register);

    try root.put("code_2fa", code_2fa);

    const mailer = request.mail("2fa", .{ .subject = "email verification for registration", .to = &.{email} });
    try mailer.deliver(.background, .{});

    return request.redirect("/account/register/2fa", .moved_permanently);

    // try root.put("message", "alhamdo li Allah cerdintials were correct<br>now you will -incha2Allah- be redirected to confirm 2fa code");
    // return request.render(.created);

}
