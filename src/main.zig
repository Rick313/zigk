const std = @import("std");
const stdout = std.debug.print;

pub fn main() !void {
    // catch case
    var a = div(12, 0) catch |err| switch (err) {
        DivError.DivByZero => 0.0,
        else => |e| return e, // propagate
    };
    stdout("Result {d}\n", .{a});

    // catch default
    a = div(12, 0) catch 0.0;
    stdout("Result {d}\n", .{a});
}

const DivError = error{DivByZero};

fn div(numerator: f32, denominator: f32) DivError!f32 {
    if (denominator == 0) return DivError.DivByZero;
    return numerator / denominator;
}
