// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah

const std = @import("std");
const jetzig = @import("jetzig");

pub const cookie_lang_name = "lang";
pub const templates_path = "templates/";

pub const default_lang = Languages.en;

/// supported languages
pub const Languages = enum { en, ar };

pub fn setLang(request: *jetzig.Request, lang: Languages) !void {
    var cookies = try request.cookies();
    try cookies.put(.{ .name = cookie_lang_name, .value = @tagName(lang) });
}

pub fn getLang(request: *jetzig.Request) !?Languages {
    const cookies = try request.cookies();
    const language_cookie = cookies.get(cookie_lang_name) orelse return null;
    const language_cookie_value = language_cookie.value;

    inline for (@typeInfo(Languages).@"enum".fields) |field| {
        if (std.mem.eql(u8, field.name, language_cookie_value)) return @enumFromInt(field.value);
    }

    return null;
}

pub fn renderLang(request: *jetzig.Request, status: jetzig.http.status_codes.StatusCode, layout_optional: ?[]const u8, template: []const u8, language: Languages) !jetzig.View {
    if (layout_optional) |layout| {
        request.setLayout(try std.mem.concat(request.allocator, u8, &.{ @tagName(language), "/", layout }));
    }
    request.setTemplate(try std.mem.concat(request.allocator, u8, &.{ templates_path, @tagName(language), "/", template }));

    // std.debug.print("alhamdo li Allah layout: '{s}'\n", .{request.layout orelse "(null)"});
    // std.debug.print("alhamdo li Allah template: '{s}'\n", .{request.dynamic_assigned_template orelse "(null)"});

    return request.render(status);
}

pub fn render(request: *jetzig.Request, status: jetzig.http.status_codes.StatusCode, layout_optional: ?[]const u8, template: []const u8) !jetzig.View {
    // const language = try getLang(request) orelse return request.render(status);
    const language = try getLang(request) orelse default_lang;

    return renderLang(request, status, layout_optional, template, language);
}
