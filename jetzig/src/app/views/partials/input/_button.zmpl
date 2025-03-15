@args content: []const u8 = "", button_type: []const u8 = "button", extra_classes: []const u8 = "", extra_attributes: []const u8 = ""

<button type="{{ button_type }}" class="flex w-full justify-center rounded-md bg-indigo-600 px-3 py-1.5 text-sm/6 font-semibold text-white shadow-2xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 {{ extra_classes }}" {{ extra_attributes }}> {{ content }} </button>
