// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");

const multiling = @import("multiling.zig");

pub fn renderError(request: *jetzig.Request) !jetzig.View {
    return request.fail(.internal_server_error);
}
