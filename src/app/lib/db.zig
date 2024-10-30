// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");
const pg = @import("pg");

pub var pool: ?*pg.Pool = null;

var gpa: std.heap.GeneralPurposeAllocator(.{}) = undefined;
var allocator: std.mem.Allocator = undefined;

// pub fn init(size: u8) !void {
//     gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     allocator = gpa.allocator();
//
//     pool = try pg.Pool.init(allocator, .{ .size = size, .connect = .{
//         .port = 5432,
//         .host = "127.0.0.1",
//     }, .auth = .{
//         .username = "postgres",
//         .database = "bismi_allah_db",
//         .password = "bismi_allah",
//         .timeout = 10_000,
//     } });
//
//     if (null == pool) std.debug.print("alhamdo li Allah error cuse pool is null. it will get to unreachable now so no need to stop it :)\n", .{});
//
//     var conn = try pool.?.acquire();
//     conn.deinit();
// }

pub fn deinit() void {
    pool.?.deinit();
}

/// you need to call `conn.release()`
/// on the result
// pub fn acquire() !*pg.Conn {
//     if (pool) |pool_real| {
//         return try pool_real.acquire();
//     } else {
//         try init(4);
//         return try pool.?.acquire();
//     }
// }

pub const User = struct {
    pub const Error = error{
        WrongLogin,
        WrongEmail,
        WrongPassword,
    };
    const password_salt_length = 12;
    const max_password_size = 128;

    fn getById(conn: *pg.Conn, id: i32) !?*pg.QueryRow {
        // var result =
        return try conn.row("select id, login, email from users where id = $1", .{id});
        // defer result.deinit();
    }

    /// (id, name, email, password_hash, password_salt)
    fn getByLogin(conn: *pg.Conn, login: []const u8) !?pg.Row {
        var stmt = try conn.*.prepare("select id, login, email, password_hash, password_salt from users where login = $1");
        errdefer stmt.deinit();

        try stmt.bind(login);
        var result = try stmt.execute();
        if (try result.next()) |row| {
            return row;
        } else return Error.WrongLogin;
    }

    /// when logging in -incha2Allah-
    pub fn getAuth(conn: *pg.Conn, login: []const u8, password: []const u8, email: []const u8, data: *jetzig.Data) !*jetzig.Data.Value {
        var user_row = try getByLogin(conn, login) orelse {
            return Error.WrongLogin;
        };
        // defer user_row.drain();

        const id = user_row.get(i32, 0);
        const row_email = user_row.get([]u8, 2);
        const password_hash = user_row.get([]u8, 3);
        const password_salt = user_row.get([]u8, 4);

        // DONOT uncomment this line
        // it only gets here if it is correct
        // if (!std.mem.eql(u8, row_login, login)) return Error.WrongLogin;
        if (!std.mem.eql(u8, row_email, email)) {
            return Error.WrongLogin;
        }
        check_password: {
            var buff_in: [max_password_size + password_salt_length]u8 = undefined;
            std.mem.copyForwards(u8, buff_in[0..password.len], password);
            std.mem.copyForwards(u8, buff_in[password.len..], password_salt);

            var buff_out: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
            std.crypto.hash.sha2.Sha256.hash(buff_in[0 .. password.len + password_salt_length], &buff_out, .{});

            const buff_password_hash_hex: [64]u8 = std.fmt.bytesToHex(buff_out, .lower);

            if (!std.mem.eql(u8, password_hash, &buff_password_hash_hex)) {
                return Error.WrongPassword;
            }
            break :check_password;
        }

        var user_object = try data.object();

        try user_object.put("id", data.integer(id));
        try user_object.put("login", data.string(login));
        try user_object.put("email", data.string(email));

        return user_object;
    }
};
