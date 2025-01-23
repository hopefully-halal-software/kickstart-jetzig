<!DOCTYPE html>
<html lang="en">
@zig {
    const links = .{
        .{ .href = "/", .title = "Home" },
        .{ .href = "/account", .title = "Account" },
    };
}
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>bismi Allah website</title>
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
