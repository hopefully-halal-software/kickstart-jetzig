// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");

pub const Cipher = std.crypto.aead.chacha_poly.XChaCha20Poly1305;

/// bismi Allah:
/// create an `*jetzig.Data.Value` from an
/// encypted then base64-encoded `*jetzig.Data.Value`
/// `
/// var test_object = try data.object();
/// try test_object.put("bismi_allah", data.string("bismi_allah"));
/// try test_object.put("bismi_allah2", data.string("bismi_allah2"));
/// const test_object_encoded = try security.encodeValueToEncryptedBase64(request, test_object);
/// const test_object_parsed = try security.parseValueFromEncryptedBase64(request, test_object_encoded);
/// `
pub fn parseValueFromEncryptedBase64(request: *jetzig.Request, value: []const u8) !*jetzig.Data.Value {
    const decoded = try jetzig.util.base64Decode(request.allocator, value);
    defer request.allocator.free(decoded);

    const decrypted = try decrypt(request, decoded);
    defer request.allocator.free(decrypted);

    return try request.response_data.parseJsonSlice(decrypted);
}

/// bismi Allah:
/// encrypt and base64-encode a Value
/// `
/// var test_object = try data.object();
/// try test_object.put("bismi_allah", data.string("bismi_allah"));
/// try test_object.put("bismi_allah2", data.string("bismi_allah2"));
/// const test_object_encoded = try security.encodeValueToEncryptedBase64(request, test_object);
/// `
pub fn encodeValueToEncryptedBase64(request: *jetzig.Request, value: *jetzig.Data.Value) ![]u8 {
    const json = try value.toJson();

    const encrypted = try encrypt(request, json);
    defer request.allocator.free(encrypted);
    const encoded = try jetzig.util.base64Encode(request.allocator, encrypted);
    return encoded;
}

pub fn decrypt(request: *jetzig.Request, value: []const u8) ![]u8 {
    if (value.len < Cipher.nonce_length + Cipher.tag_length) return error.JetzigInvalidSessionCookie;

    const secret_bytes = std.mem.sliceAsBytes(request.server.env.secret);
    const key = secret_bytes[0..Cipher.key_length];
    const nonce = value[0..Cipher.nonce_length];
    const buf = try request.allocator.alloc(u8, value.len - Cipher.tag_length - Cipher.nonce_length);
    errdefer request.allocator.free(buf);
    const associated_data = "";
    var tag: [Cipher.tag_length]u8 = undefined;
    @memcpy(&tag, value[value.len - Cipher.tag_length ..]);

    try Cipher.decrypt(
        buf,
        value[Cipher.nonce_length .. value.len - Cipher.tag_length],
        tag,
        associated_data,
        nonce.*,
        key.*,
    );
    return buf;
}

pub fn encrypt(request: *jetzig.Request, value: []const u8) ![]u8 {
    const secret_bytes = std.mem.sliceAsBytes(request.server.env.secret);
    const key: [Cipher.key_length]u8 = secret_bytes[0..Cipher.key_length].*;
    var nonce: [Cipher.nonce_length]u8 = undefined;
    for (0..Cipher.nonce_length) |index| nonce[index] = std.crypto.random.int(u8);
    const associated_data = "";

    const buf = try request.allocator.alloc(u8, value.len);
    defer request.allocator.free(buf);
    var tag: [Cipher.tag_length]u8 = undefined;

    Cipher.encrypt(buf, &tag, value, associated_data, nonce, key);
    const encrypted = try std.mem.concat(
        request.allocator,
        u8,
        &[_][]const u8{ &nonce, buf, tag[0..] },
    );
    return encrypted;
}
