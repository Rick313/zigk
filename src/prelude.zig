const std = @import("std");

/// Read input limited to 1mio
pub fn readline(io: std.Io) ![]u8 {
    var buffer: [1024 * 1024]u8 = undefined;
    var stdin: std.Io.File.Reader = .init(.stdin(), io, &buffer);
    return try stdin.interface.takeDelimiterExclusive('\n');
}

/// Write line limited to 1204ko
pub fn print(io: std.Io, comptime fmt: []const u8, args: anytype) !void {
    var buffer: [1024]u8 = undefined;
    var stdout: std.Io.File.Writer = .init(.stdout(), io, &buffer);
    try stdout.interface.print(fmt, args);
    try stdout.interface.flush();
}

/// Write line and break limited to 1204ko
pub fn println(io: std.Io, comptime fmt: []const u8, args: anytype) !void {
    try print(io, fmt ++ "\n", args);
}
