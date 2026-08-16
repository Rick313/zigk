const std = @import("std");
const Base64 = @import("base64.zig").Base64;
const Init = std.process.Init;
const Io = std.Io;
const Allocator = std.mem.Allocator;

pub fn main(_: Init.Minimal) !void {
    const allocator = std.heap.page_allocator;
    var threaded: Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();

    const io = threaded.io();

    const encoded = try Base64.encode(allocator, "Hi");
    const decoded = try Base64.decode(allocator, encoded);
    defer allocator.free(encoded);
    defer allocator.free(decoded);

    var buffer: [1024]u8 = undefined;
    var writer: Io.File.Writer = .init(.stdout(), io, &buffer);
    try writer.interface.print("Encoded: {s}\nDecoded: {s}\n", .{ encoded, decoded });
    try writer.flush();
}
