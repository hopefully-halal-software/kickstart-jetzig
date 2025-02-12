// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
pub const database = .{
    // Null adapter fails when a database call is invoked.
    // .development = .{
    //     .adapter = .null,
    // },
    // .testing = .{
    //     .adapter = .null,
    // },
    // .production = .{
    //     .adapter = .null,
    // },

    // PostgreSQL adapter configuration.
    //
    // All options except `adapter` can be configured using environment variables:
    //
    // * JETQUERY_HOSTNAME
    // * JETQUERY_PORT
    // * JETQUERY_USERNAME
    // * JETQUERY_PASSWORD
    // * JETQUERY_DATABASE

    .testing = .{
        .adapter = .postgresql,
        .hostname = "localhost",
        .port = 5432,
        .username = "postgres",
        .password = "bismi_allah",
        .database = "bismi_allah_db_testing",
    },

    .development = .{
        .adapter = .postgresql,
        .hostname = "127.0.0.1",
        .port = 5432,
        .username = "postgres",
        .password = "bismi_allah",
        .database = "bismi_allah",
    },

    .production = .{
        .adapter = .postgresql,
        .hostname = "127.0.0.1",
        .port = 5432,
        .username = "postgres",
        .password = "bismi_allah",
        .database = "bismi_allah",
    },
};
