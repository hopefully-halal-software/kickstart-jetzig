// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");

const multiling = @import("multiling.zig");

pub fn render(request: *jetzig.Request, status: jetzig.http.status_codes.StatusCode, error_message: []const u8, layout_optional: ?[]const u8) !jetzig.View {
    var root = try request.data(.object);
    try root.put("error_message", error_message);
    return multiling.render(request, status, layout_optional, "errors");
}
