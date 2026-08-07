const std = @import("std");
const stdout = std.debug.print;

pub fn main() !void {
    // Defer is used to execute a statement upon exiting the current block.
    defer stdout("Good bye dude !\n", .{});
    stdout("Welcome Zig !\n", .{});
    stdout("This is a short program written in zig.\n", .{});
}
