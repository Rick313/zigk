const std = @import("std");
const stdout = std.debug.print;

pub fn main() !void {
    var john = Hero{ .name = "John", .life_pt = 10, .attack_pt = 2 };
    var bob = Hero{ .name = "Bob", .life_pt = 12, .attack_pt = 1 };
    john.attack(&bob);
    try bob.showLife();
}

const Hero = struct {
    name: []const u8,
    life_pt: u32,
    attack_pt: u32,
    pub fn attack(self: Hero, target: *Hero) void {
        stdout("[{s}] Attack {s} ! \n", .{ self.name, target.name });
        target.life_pt -= self.attack_pt;
    }
    pub fn showLife(self: Hero) !void {
        stdout("[{s}] My life point is {d}. \n", .{ self.name, self.life_pt });
    }
};
