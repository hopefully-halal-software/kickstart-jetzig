// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");

pub const cookie_lang_name = "lang";
pub const templates_path = "templates/";

pub const default_lang = "en";

/// supported languages
pub const Language = enum { en, ar };

pub fn setLang(request: *jetzig.Request, lang: Language) !void {
    var cookies = try request.cookies();
    try cookies.put(.{ .name = cookie_lang_name, .value = lang });
}

pub fn getLang(request: *jetzig.Request) !?Language {
    const cookies = try request.cookies();
    const langue_cookie = cookies.get(cookie_lang_name) orelse return null;

    return langue_cookie.value;
}

pub fn render(request: *jetzig.Request, status: jetzig.http.status_codes.StatusCode, layout_optional: ?[]const u8, template: []const u8) !jetzig.View {
    // const language = try getLang(request) orelse return request.render(status);
    const language = try getLang(request) orelse default_lang;

    if (layout_optional) |layout| {
        request.setLayout(try std.mem.concat(request.allocator, u8, &.{ language, "/", layout }));
    }
    request.setTemplate(try std.mem.concat(request.allocator, u8, &.{ templates_path, language, "/", template }));

    // std.debug.print("alhamdo li Allah layout: '{s}'\n", .{request.layout orelse "(null)"});
    // std.debug.print("alhamdo li Allah template: '{s}'\n", .{request.dynamic_assigned_template orelse "(null)"});

    return request.render(status);
}
