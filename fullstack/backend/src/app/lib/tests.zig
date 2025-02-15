// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");

pub fn login(app: *jetzig.testing.App) !void {
    try app.initSession();
    var user = try app.session.data.object();
    try user.put("id", 1);
    try user.put("name", app.session.data.string("bismi_allah_user"));
    try user.put("email", app.session.data.string("ouhamouy10@gmail.com"));

    try app.session.put("user", user);
}

pub fn loginWithId(app: *jetzig.testing.App, id: i32) !void {
    try app.initSession();
    var user = try app.session.data.object();
    try user.put("id", app.session.data.integer(id));
    try user.put("name", app.session.data.string("bismi_allah_username"));
    try user.put("email", app.session.data.string("ouhamouy10@gmail.com"));

    try app.session.put("user", user);
}
