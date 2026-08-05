const std = @import("std");
const stdout = std.debug.print;

pub fn main() !void {
    const prices = [_]f32{ 5.50, 2.30, 1.90 };
    stdout("Total price {} \n", .{total(&prices)}); // <- pass pointer ref
}

fn total(xs: []const f32) f32 {
    var output: f32 = 0;
    for (xs) |x| output += x;
    return output;
}
