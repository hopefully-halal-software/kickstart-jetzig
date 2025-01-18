@zig {
    const links = .{
        .{ .href = "/", .title = "الرئيسية" },
        .{ .href = "/account", .title = "الحساب" },
    };
}

<nav>
    <div>
    </div>
    <div>
        <ul style="flex-direction: row-reverse;">
        @zig {
            inline for(links) |link| {
                <li><a href="{{ link.href }}">{{ link.title }}</a></li>
            }
        }
            <li>
                @partial layouts/all/select_lang
            </li>
        </ul>
    </div>
</nav>
