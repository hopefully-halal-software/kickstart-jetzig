// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed rassoul Allah
const std = @import("std");
const jetzig = @import("jetzig");

pub const layout = "main";

/// `src/app/views/root.zig` represents the root URL `/`
/// The `index` view function is invoked when when the HTTP verb is `GET`.
/// Other view types are invoked either by passing a resource ID value (e.g. `/1234`) or by using
/// a different HTTP verb:
///
/// GET / => index(request, data)
/// GET /1234 => get(id, request, data)
/// POST / => post(request, data)
/// PUT /1234 => put(id, request, data)
/// PATCH /1234 => patch(id, request, data)
/// DELETE /1234 => delete(id, request, data)
pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;


    return request.render(.ok);
}
