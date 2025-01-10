// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah
const std = @import("std");
const builtin = @import("builtin");
const jetzig = @import("jetzig");
const pg = @import("pg");

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
//         .database = "bismi_allah_idz",
//         .password = "bismi_allah",
//         .timeout = 10_000,
//     } });
//
//     if (null == pool) std.debug.print("alhamdo li Allah error cuse pool is null. it will get to unreachable now so no need to stop it :)\n", .{});
//
//     var conn = try pool.?.acquire();
//     conn.deinit();
// }

pub fn deinit(pool: *pg.Pool) void {
    pool.deinit();
}

pub fn initDb(pool: *pg.Pool) !void {
    var conn = try pool.acquire();
    defer conn.release();

    try User.initDb(conn);

    if (builtin.mode == .Debug) {
        _ = conn.exec("INSERT INTO users VALUES (1, 'bismi_allah_user', 'ouhamouy10@gmail.com', '5a26cff1f99a18b5ccdd414d4e967898fb5fee3ef47bae419d2fbbadf4a60890', '123456789012')", .{}) catch |err| {
            if (err != error.PG) return err;
            if (conn.err) |pge| std.log.err("alhamdo li Allah error: {s}\n", .{pge.message});
        };

        // init other data
    }
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

    fn initDb(conn: *pg.Conn) !void {
        _ = conn.exec(
            \\CREATE TABLE IF NOT EXISTS users (                                                                    
            \\  id SERIAL PRIMARY KEY,
            \\  login VARCHAR(24) NOT NULL UNIQUE,
            \\  email VARCHAR(50) NOT NULL,
            \\  password_hash CHAR(64) NOT NULL,
            \\  password_salt CHAR(12) NOT NULL
            \\)
        , .{}) catch |err| {
            if (err != error.PG) return err;
            if (conn.err) |pge| std.log.err("alhamdo li Allah error: {s}\n", .{pge.message});
        };
    }

    /// when logging in -incha2Allah-
    pub fn getAuth(conn: *pg.Conn, login: []const u8, password: []const u8, email: []const u8, data: *jetzig.Data) !*jetzig.Data.Value {
        // var stmt = try conn.*.prepare("select id, login, email, password_hash, password_salt from users where login = $1");
        var stmt = try conn.*.prepare("select * from users where login = $1");
        errdefer stmt.deinit();

        var user_row: pg.Row = undefined;

        try stmt.bind(login);
        var result = try stmt.execute();
        if (try result.next()) |row| {
            user_row = row;
        } else return Error.WrongLogin;
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

        try result.drain();

        return user_object;
    }

    pub fn exists(conn: *pg.Conn, login: []const u8) !bool {
        var stmt = conn.prepare("SELECT id FROM users WHERE login = $1") catch |err| {
            if (err != error.PG) return err;
            if (conn.err) |pge| std.log.err("alhamdo li Allah error while inserting a user: {s}\n", .{pge.message});
            return err;
        };
        errdefer stmt.deinit();

        try stmt.bind(login);
        var result = try stmt.execute();

        if (try result.next()) |row| {
            _ = row;

            try result.drain();
            return true;
        }

        try result.drain();
        return false;
    }

    pub fn insertUser(conn: *pg.Conn, login: []const u8, email: []const u8, password: []const u8) !void {
        var stmt = conn.prepare("INSERT INTO users (login, email, password_hash, password_salt) VALUES ($1, $2, $3, $4)") catch |err| {
            if (err != error.PG) return err;
            if (conn.err) |pge| std.log.err("alhamdo li Allah error while inserting a user: {s}\n", .{pge.message});
            return err;
        };
        errdefer stmt.deinit();

        var password_salt: [12]u8 = undefined;
        var password_hash: [64]u8 = undefined;
        // generate password salt
        {
            var password_salt_raw: [6]u8 = undefined;
            std.crypto.random.bytes(&password_salt_raw);
            password_salt = std.fmt.bytesToHex(&password_salt_raw, .lower);
        }
        // generate password hash
        {
            var password_and_salt_buffer: [max_password_size + password_salt_length]u8 = undefined;
            std.mem.copyForwards(u8, password_and_salt_buffer[0..password.len], password);
            std.mem.copyForwards(u8, password_and_salt_buffer[password.len..], &password_salt);

            var password_hash_raw: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
            std.crypto.hash.sha2.Sha256.hash(password_and_salt_buffer[0 .. password.len + password_salt_length], &password_hash_raw, .{});
            password_hash = std.fmt.bytesToHex(password_hash_raw, .lower);
        }

        try stmt.bind(login);
        try stmt.bind(email);
        try stmt.bind(password_hash);
        try stmt.bind(password_salt);
        var result = try stmt.execute();
        try result.drain();
    }
};
