// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");
const libs = @import("../../lib/all.zig");

pub const layout = "main";

pub fn index(request: *jetzig.Request) !jetzig.View {
    const Params = struct {
        data: []const u8,
    };
    const params = try request.expectParams(Params) orelse return libs.errors.render(request, .unprocessable_entity, .need_to_pass_arguments, layout);

    const root = try request.data(.object);

    const data = try libs.security.parseValueFromEncryptedBase64(request, params.data);
    if (try libs.payment.parseDataRenderOnError(request, data, layout)) |capture| return capture;

    try root.put("data", params.data);
    try root.put("data_decrypted", data);

    return libs.multiling.render(request, .ok, layout, "utils/payment/index");
}

pub fn post(request: *jetzig.Request) !jetzig.View {
    var root = try request.data(.object);

    const Params = struct {
        data: []const u8,
    };
    const params = try request.expectParams(Params) orelse return libs.errors.render(request, .unprocessable_entity, .need_to_pass_arguments, layout);

    const data = try libs.security.parseValueFromEncryptedBase64(request, params.data);
    if (try libs.payment.parseDataRenderOnError(request, data, layout)) |capture| return capture;

    if (.production == jetzig.environment) {
        @compileError("alhamdo li Allah, you need to implement payment logic to make it work in production :) \n");
    }

    const payload_encrypted = data.getT(.string, "payload") orelse return libs.errors.render(request, .internal_server_error, .something_went_wrong, layout);
    const target_url = data.getT(.string, "target_url") orelse return libs.errors.render(request, .internal_server_error, .something_went_wrong, layout);

    try root.put("payload_encrypted", payload_encrypted);
    try root.put("target_url", target_url);

    return libs.multiling.render(request, .created, layout, "utils/payment/post");
}

test "index" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/utils/payment", .{});
    try response.expectStatus(.ok);
}

test "post" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.POST, "/utils/payment", .{});
    try response.expectStatus(.created);
}
