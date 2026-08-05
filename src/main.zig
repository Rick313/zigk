const std = @import("std");
const stdout = std.debug.print;

pub fn main() !void {
    stdout("Score: {d} \n", .{add(1, 2)});
    stdout("2 is odd {} \n", .{isOdd(2)});
    stdout("2 is even {} \n", .{isEven(2)});
}

fn add(a: i32, b: i32) i32 {
    return a + b;
}

fn isOdd(n: u32) bool {
    return n % 2 == 0;
}

fn isEven(n: u32) bool {
    return !isOdd(n);
}
