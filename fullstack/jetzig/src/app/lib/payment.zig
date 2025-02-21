// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");
const security = @import("security.zig");
const render = @import("render.zig").render;

pub const payment_path = "/api/v1/utils/payment";

/// supported languages
pub const Currencies = enum {
    AFN, // AFN — Afghan Afghani
    MYR, // MYR — Malaysian Ringgit
    USD, // repoted use by some westners hhhhhhh
};

pub fn redirectPayment(request: *jetzig.Request, amount: i32, currency: Currencies, expire_after_minutes: i34, target_url: []const u8, payload: *jetzig.Data.Value) !jetzig.View {
    _ = try request.data(.object);

    var value = try request.response_data.object();
    try value.put("payload", request.response_data.string(try security.encodeValueToEncryptedBase64(request, payload)));
    try value.put("expire", request.response_data.integer(std.time.timestamp() + (expire_after_minutes * 60)));
    try value.put("target_url", request.response_data.string(target_url));
    try value.put("amount", request.response_data.integer(amount));
    try value.put("currency", request.response_data.string(@tagName(currency)));

    const data = try security.encodeValueToEncryptedBase64(request, value);

    const path = try std.mem.concat(request.allocator, u8, &.{ payment_path, "?data=", data });

    return request.redirect(path, .found);
}

pub fn parseDataRenderOnError(request: *jetzig.Request, data: *jetzig.Data.Value) !?jetzig.View {
    const timestamp = std.time.timestamp();

    // check expire
    {
        const expire = data.getT(.integer, "expire") orelse return try render(request, .internal_server_error, "internal error");
        if (expire < timestamp) return try render(request, .unprocessable_entity, "token expired");
    }

    return null;
}
