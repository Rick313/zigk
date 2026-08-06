const std = @import("std");
const stdout = std.debug.print;

pub fn main() !void {
    const john = User{ .first_name = "John", .last_name = "Doe" };
    try john.greeting();
}

const User = struct {
    first_name: []const u8,
    last_name: []const u8,

    pub fn greeting(self: User) !void {
        stdout("Hello {s} {s} !\n", .{ self.first_name, self.last_name });
    }
};
