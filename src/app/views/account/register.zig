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

    if (try db.User.exists(conn, "login")) {
        try root.put("message", data.string("login is already used by another user"));
    }

    const session = try request.session();

    var user = try data.object();
    try user.put("login", data.string(login));
    try user.put("email", data.string(email));
    try user.put("password", data.string(password));

    var session_2fa_register = try data.object();
    try session.put("2fa_register", session_2fa_register);
    try session_2fa_register.put("user", user);
    try session.put("user", user);

    return request.redirect("/account/register/2fa", .moved_permanently);

    // try root.put("message", "alhamdo li Allah cerdintials were correct<br>now you will -incha2Allah- be redirected to confirm 2fa code");
    // return request.render(.created);

}
