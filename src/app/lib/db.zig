// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");
const pg = @import("pg");

var test_gpa: std.heap.GeneralPurposeAllocator(.{}) = undefined;
var test_allocator: std.mem.Allocator = undefined;

var test_pool: ?*pg.Pool = null;

fn testPool() !*pg.Pool {
    if (jetzig.environment != .testing) @compileError("alhamdo li Allah: testPool() should not be called outside of tests");

    // called from aqcuire()
    // if (null != test_pool) return test_pool.?;

    test_gpa = std.heap.GeneralPurposeAllocator(.{}){};
    test_allocator = test_gpa.allocator();

    {
        const pool = try pg.Pool.init(test_allocator, .{ .size = 1, .connect = .{
            .port = 5432,
            .host = "127.0.0.1",
        }, .auth = .{
            .username = "postgres",
            .database = "postgres",
            .password = "bismi_allah",
            .timeout = 10_000,
        } });
        defer pool.deinit();

        _ = pool.exec("DROP DATABASE IF EXISTS bismi_allah_db_test", .{}) catch |err| std.debug.print("alhamdo li Allah error on test pool init 'drop test db': '{any}'\n", .{err});
        _ = pool.exec("CREATE DATABASE bismi_allah_db_test", .{}) catch |err| std.debug.print("alhamdo li Allah error on test pool init 'create test db': '{any}'\n", .{err});
    }

    const pool = try pg.Pool.init(test_allocator, .{ .size = 4, .connect = .{
        .port = 5432,
        .host = "127.0.0.1",
    }, .auth = .{
        .username = "postgres",
        .database = "bismi_allah_db_test",
        .password = "bismi_allah",
        .timeout = 10_000,
    } });

    try initDb(pool);

    return pool;
}

pub inline fn acquire(request: *jetzig.Request) !*pg.Conn {
    if (jetzig.environment == .testing) {
        if (test_pool) |pool| return pool.acquire() else {
            test_pool = try testPool();
            return test_pool.?.acquire();
        }
    } else {
        return request.global.pool.acquire();
    }
}

pub fn deinit(pool: *pg.Pool) void {
    pool.deinit();
}

pub fn initDb(pool: *pg.Pool) !void {
    var conn = try pool.acquire();
    defer conn.release();
    errdefer pool.deinit();

    try User.initDb(conn);

    if (jetzig.environment != .production) {
        User.insertUser(conn, "bismi_allah_user", "ouhamouy10@gmail.com", "bismi_allah") catch |err| if (err != error.UnexpectedDBMessage and err != error.PG) std.debug.print("alhamdo li Allah error 3: '{any}'\n", .{err});
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
        WrongEmail,
        WrongPassword,
    };
    const password_salt_length = 12;
    const max_password_size = 128;

    fn initDb(conn: *pg.Conn) !void {
        _ = conn.exec(
            \\CREATE TABLE IF NOT EXISTS users (                                                                    
            \\  id SERIAL PRIMARY KEY,
            \\  name VARCHAR(34) NOT NULL UNIQUE,
            \\  email VARCHAR(50) NOT NULL UNIQUE,
            \\  password_hash CHAR(64) NOT NULL,
            \\  password_salt CHAR(12) NOT NULL
            \\)
        , .{}) catch |err| {
            if (err != error.PG) return err;
            if (conn.err) |pge| std.log.err("alhamdo li Allah error: {s}\n", .{pge.message});
        };
    }

    /// when logging in -incha2Allah-
    pub fn getAuth(conn: *pg.Conn, email: []const u8, password: []const u8, data: *jetzig.Data) !*jetzig.Data.Value {
        // var stmt = try conn.*.prepare("select id, name, password_hash, password_salt from users where email = $1");
        var stmt = try conn.*.prepare("select * from users where email = $1");
        errdefer stmt.deinit();

        var user_row: pg.Row = undefined;

        try stmt.bind(email);
        var result = try stmt.execute();
        if (try result.next()) |row| {
            user_row = row;
        } else return Error.WrongEmail;
        // defer user_row.drain();

        const id = user_row.get(i32, 0);
        const row_name = user_row.get([]u8, 1);
        const row_email = user_row.get([]u8, 2);
        const password_hash = user_row.get([]u8, 3);
        const password_salt = user_row.get([]u8, 4);

        // DONOT uncomment this line
        // it only gets here if it is correct
        // if (!std.mem.eql(u8, row_email, email)) return Error.WrongEmail;
        if (!std.mem.eql(u8, row_email, email)) {
            return Error.WrongEmail;
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
        try user_object.put("name", data.string(row_name));
        try user_object.put("email", data.string(email));

        try result.drain();

        return user_object;
    }

    pub fn existsByName(conn: *pg.Conn, name: []const u8) !bool {
        var stmt = conn.prepare("SELECT id FROM users WHERE name = $1") catch |err| {
            if (err != error.PG) return err;
            if (conn.err) |pge| std.log.err("alhamdo li Allah error while inserting a user: {s}\n", .{pge.message});
            return err;
        };
        errdefer stmt.deinit();

        try stmt.bind(name);
        var result = try stmt.execute();

        if (try result.next()) |row| {
            _ = row;

            try result.drain();
            return true;
        }

        try result.drain();
        return false;
    }

    pub fn existsByEmail(conn: *pg.Conn, email: []const u8) !bool {
        var stmt = conn.prepare("SELECT id FROM users WHERE email = $1") catch |err| {
            if (err != error.PG) return err;
            if (conn.err) |pge| std.log.err("alhamdo li Allah error while inserting a user: {s}\n", .{pge.message});
            return err;
        };
        errdefer stmt.deinit();

        try stmt.bind(email);
        var result = try stmt.execute();

        if (try result.next()) |row| {
            _ = row;

            try result.drain();
            return true;
        }

        try result.drain();
        return false;
    }

    pub fn insertUser(conn: *pg.Conn, name: []const u8, email: []const u8, password: []const u8) !void {
        var stmt = conn.prepare("INSERT INTO users (name, email, password_hash, password_salt) VALUES ($1, $2, $3, $4)") catch |err| {
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

        try stmt.bind(name);
        try stmt.bind(email);
        try stmt.bind(password_hash);
        try stmt.bind(password_salt);
        var result = try stmt.execute();
        try result.drain();
        result.deinit();
    }

    pub fn setPassword(conn: *pg.Conn, email: []const u8, new_password: []const u8) !void {
        var stmt = try conn.prepare("UPDATE users SET password_hash = $1, password_salt = $2 WHERE email = $3");
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
            std.mem.copyForwards(u8, password_and_salt_buffer[0..new_password.len], new_password);
            std.mem.copyForwards(u8, password_and_salt_buffer[new_password.len..], &password_salt);

            var password_hash_raw: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
            std.crypto.hash.sha2.Sha256.hash(password_and_salt_buffer[0 .. new_password.len + password_salt_length], &password_hash_raw, .{});
            password_hash = std.fmt.bytesToHex(password_hash_raw, .lower);
        }

        try stmt.bind(password_hash);
        try stmt.bind(password_salt);
        try stmt.bind(email);
        var result = try stmt.execute();
        try result.drain();
    }

    pub fn deleteUserByEmail(conn: *pg.Conn, email: []const u8) !void {
        var stmt = conn.prepare("DELETE FROM users WHERE email = $1") catch |err| {
            std.debug.print("alhamdo li Allah delete error: '{any}'\n", .{err});
            if (conn.err) |pge| std.debug.print("alhamdo li Allah db on delete message: '{s}'\n", .{pge.message});
            return err;
        };
        errdefer stmt.deinit();

        try stmt.bind(email);

        var result = try stmt.execute();
        try result.drain();
        result.deinit();
    }
};
