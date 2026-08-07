const std = @import("std");
const stdout = std.debug.print;

pub fn main() !void {
    const txt1 = "Hello";
    const txt2 = "Zig !";

    const msg =
        if (std.mem.eql(u8, txt1, txt2)) "It's the same bytes !" else "They're differents !";

    stdout("{s}\n", .{msg});
}
