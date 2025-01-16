// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");

pub const cookie_lang_name = "lang";
pub const templates_path = "templates/";

pub fn setLang(request: *jetzig.Request, lang: []const u8) !void {
    var cookies = try request.cookies();
    try cookies.put(.{ .name = cookie_lang_name, .value = lang });
}

pub fn getLang(request: *jetzig.Request) !?[]const u8 {
    const cookies = try request.cookies();
    const langue_cookie = cookies.get(cookie_lang_name) orelse return null;
    return langue_cookie.value;
}

pub fn render(request: *jetzig.Request, status: jetzig.http.status_codes.StatusCode, layout_optional: ?[]const u8, template: []const u8) !jetzig.View {
    const language = try getLang(request) orelse return request.render(status);

    if (layout_optional) |layout| {
        request.setLayout(try std.mem.concat(request.allocator, u8, &.{ language, "/", layout }));
    }
    request.setTemplate(try std.mem.concat(request.allocator, u8, &.{ templates_path, language, "/", template }));

    return request.render(status);
}
