// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");
const security = @import("security.zig");
const errors = @import("errors.zig");
const Actions = @import("actions.zig").Actions;

pub const payment_path = "/utils/payment";

/// supported languages
pub const Currencies = enum {
    AFN, // AFN — Afghan Afghani
    MYR, // MYR — Malaysian Ringgit
    USD, // repoted use by some westners hhhhhhh
};

pub fn redirectPayment(request: *jetzig.Request, amount: i32, currency: Currencies, expire_after_minutes: i34, action: Actions, payload: *jetzig.Data.Value) !jetzig.View {
    _ = try request.data(.object);

    var value = try request.response_data.object();
    try value.put("payload", request.response_data.string(try security.encodeValueToEncryptedBase64(request, payload)));
    try value.put("expire", request.response_data.integer(std.time.timestamp() + (expire_after_minutes * 60)));
    try value.put("action", request.response_data.string(@tagName(action)));
    try value.put("amount", request.response_data.integer(amount));
    try value.put("currency", request.response_data.string(@tagName(currency)));

    const data = try security.encodeValueToEncryptedBase64(request, value);

    const path = try std.mem.concat(request.allocator, u8, &.{ payment_path, "?data=", data });

    return request.redirect(path, .found);
}

pub fn parseDataRenderOnError(request: *jetzig.Request, data: *jetzig.Data.Value, layout: ?[]const u8) !?jetzig.View {
    const timestamp = std.time.timestamp();

    // check expire
    {
        const expire = data.getT(.integer, "expire") orelse return try errors.render(request, .internal_server_error, .internal_error, layout);
        if (expire < timestamp) return try errors.render(request, .unprocessable_entity, .token_expired, layout);
    }

    return null;
}
