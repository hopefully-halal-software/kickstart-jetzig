<!DOCTYPE html>
<html dir="rtl" lang="ar">
@zig {
    const links = .{
        .{ .href = "/", .title = "الرئيسية" },
        .{ .href = "/account", .title = "الحساب" },
    };
}
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>بسم الله الرحمن الرحيم</title>
    <link href="/bismi_allah.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <header>
        @partial layouts/all/nav(links: links)
    </header>
    <main>{{zmpl.content}}</main>
    <footer></footer>
</body>
</html>
