const std = @import("std");
const stdout = std.debug.print;

pub fn main() !void {
    var compter: i32 = 10;

    while (compter >= 0) {
        if (compter > 0) {
            stdout("Warning {d} \n", .{compter});
        } else stdout("Boum ! \n", .{});
        compter -= 1;
    }
}
