const std = @import("std");
const Init = std.process.Init;
const Io = std.Io;
const Allocator = std.mem.Allocator;
const Thread = std.Thread;

pub fn main(_: Init.Minimal) !void {
    const allocator = std.heap.page_allocator;
    var threaded: Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();

    const io = threaded.io();

    var buffer: [1024]u8 = undefined;
    var writer: Io.File.Writer = .init(.stdout(), io, &buffer);
    try writer.interface.print("Hello zig !\n", .{});
    try writer.flush();
}
