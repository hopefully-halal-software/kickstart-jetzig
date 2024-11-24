// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");

pub const layout = "main";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    // if the user is not logged in
    // redirect them to "/account/login"
    const session = try request.session();

    if (session.get("user")) |user| {
        var root = try data.root(.object);
        try root.put("user", user);
    } else return request.redirect("/account/login", .moved_permanently);

    return request.render(.ok);
}
