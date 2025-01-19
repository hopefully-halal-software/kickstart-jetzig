// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");

const multiling = @import("multiling.zig");

const Errors = enum {
    internal_error,
    something_went_wrong,
    need_to_pass_arguments,
    need_to_pass_argument_email,
    need_to_pass_arguments_name_and_password,
    need_to_pass_arguments_name_email_and_password,
    incorrect_params,
    incorrect_email_or_password,
    email_already_used,
};

pub fn errorToString(err: Errors, lang: multiling.Languages) []const u8 {
    return switch (err) {
        .internal_error => switch (lang) {
            .en => "internal error",
            .ar => "خطأ في الخادم",
        },
        .something_went_wrong => switch (lang) {
            .en => "something went wrong",
            .ar => "حدث خطأ",
        },
        .need_to_pass_arguments => switch (lang) {
            .en => "you need to pass arguments",
            .ar => "يجب توفير المعلومات الضرورية",
        },
        .need_to_pass_argument_email => switch (lang) {
            .en => "you need to pass argument 'email'",
            .ar => "يجب توفير المعلومات الضرورية 'البريد الإلكتروني'",
        },
        .need_to_pass_arguments_name_and_password => switch (lang) {
            .en => "you need to pass arguments 'name' and 'password'",
            .ar => "يجب توفير المعلومات الضرورية 'الإسم' و 'كلمة المرور'",
        },
        .need_to_pass_arguments_name_email_and_password => switch (lang) {
            .en => "you need to pass arguments 'name', 'email' and 'password'",
            .ar => "يجب توفير المعلومات الضرورية 'الإسم', 'البريد الإلكتروني' و 'كلمة المرور'",
        },
        .email_already_used => switch (lang) {
            .en => "email is already used by another user",
            .ar => "البريد الإلكتروني مستعمل",
        },
        .incorrect_params => switch (lang) {
            .en => "incorrect params",
            .ar => "معلومات خاطئة",
        },
        .incorrect_email_or_password => switch (lang) {
            .en => "email or password were incorrect",
            .ar => "البريد الإلكتروني أو كلمة المرور خاطئة",
        },
    };
}

pub fn render(request: *jetzig.Request, status: jetzig.http.status_codes.StatusCode, err: Errors, layout_optional: ?[]const u8) !jetzig.View {
    var root = try request.data(.object);
    const lang = try multiling.getLang(request) orelse multiling.default_lang;

    try root.put("error_message", errorToString(err, lang));

    return multiling.renderLang(request, status, layout_optional, "errors", lang);
}
