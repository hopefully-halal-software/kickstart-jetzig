@args href: []const u8, title: []const u8, extra_classes: []const u8 = "", target: []const u8 = "_self"

<a href="{{ href }}" class="flex w-full justify-center rounded-md bg-indigo-600 px-3 py-1.5 text-sm/6 font-semibold text-white shadow-2xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 {{ extra_classes }}" target="{{ target }}">{{ title }}</a>
