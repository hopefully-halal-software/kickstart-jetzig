// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");
const security = @import("security.zig");
const errors = @import("errors.zig");

pub const @"2fa_path" = "/utils/2fa";

pub fn redirect2fa(request: *jetzig.Request, email: []const u8, expire_after_minutes: i34, target_url: []const u8, payload: *jetzig.Data.Value, mail_params: jetzig.mail.MailParams) !jetzig.View {
    var root = try request.data(.object);

    var value = try request.response_data.object();
    try value.put("payload", request.response_data.string(try security.encodeValueToEncryptedBase64(request, payload)));
    try value.put("expire", request.response_data.integer(std.time.timestamp() + (expire_after_minutes * 60)));
    try value.put("email", request.response_data.string(email));
    try value.put("target_url", request.response_data.string(target_url));

    {
        var code_buffer: [6]u8 = undefined;
        std.crypto.random.bytes(&code_buffer);
        const code_slice = try jetzig.util.base64Encode(request.allocator, &code_buffer);
        defer request.allocator.free(code_slice);

        const code = try request.allocator.dupe(u8, code_slice[0..8]);

        try value.put("code", code);

        try root.put("code_2fa", code);

        const mailer = request.mail("2fa", mail_params);
        try mailer.deliver(.background, .{});
    }

    const data = try security.encodeValueToEncryptedBase64(request, value);

    const path = try std.mem.concat(request.allocator, u8, &.{ @"2fa_path", "?data=", data });

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
