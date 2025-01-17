@zig {
    const links = .{
        .{ .href = "/", .title = "Home" },
        .{ .href = "/account", .title = "Account" },
    };
}

<nav>
    <div>
    </div>
    <div>
        <ul>
        @zig {
            inline for(links) |link| {
                <li><a href="{{ link.href }}">{{ link.title }}</a></li>
            }
        }
        </ul>
    </div>
</nav>
