// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");

pub const formats: jetzig.Route.Formats = .{
    .index = &.{.json},
};

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.object();

    try root.put("message", "there is no diety worthy of worship except for Allah");

    return request.render(.ok);
}
