const std = @import("std");
const Allocator = std.mem.Allocator;
const DebugAllocator = std.heap.DebugAllocator;
const ArrayList = std.ArrayList;
const Io = std.Io;
const Init = std.process.Init;

pub fn main() !void {
    try print_line("-- Todo App Started ---", .{});
    var dba: DebugAllocator(.{}) = .init;
    defer _ = dba.deinit();

    const allocator = dba.allocator();
    var list: ArrayList(Todo) = .empty;
    defer {
        for (list.items) |item| allocator.free(item.text);
        list.deinit(allocator);
    }

    try load_todos(allocator, "todos.json", &list);
    while (true) {
        try print_line("New todo: (or exit)", .{});
        var line = try read_line(allocator);
        line = std.mem.trimEnd(u8, line, "\r");
        if (std.mem.eql(u8, line, "")) {
            try print_line("Your todo can't be empty !", .{});
            continue;
        }

        if (std.mem.eql(u8, line, "exit")) {
            allocator.free(line);
            break;
        }

        try list.append(allocator, Todo{ .text = line });
    }

    try save_todos("todos.json", &list);

    try print_line("-- Final Todo list ---", .{});
    for (list.items) |item|
        try print_line(" - {s}", .{item.text});
}

// --  Business -- //
const Todo = struct {
    text: []const u8,
};

/// This is not the best way.
/// Can't read a file over 1Mio
fn load_todos(allocator: Allocator, file_name: []const u8, list: *ArrayList(Todo)) !void {
    const global_single_threaded = Io.Threaded.global_single_threaded;
    const json = Io.Dir.readFileAlloc(
        Io.Dir.cwd(),
        global_single_threaded.io(),
        file_name,
        allocator,
        .limited(1024 * 1024),
    ) catch |err| switch (err) {
        error.FileNotFound => return,
        else => return err,
    };
    defer allocator.free(json);
    if (json.len == 0) return;
    var parsed = try std.json.parseFromSlice(
        []Todo,
        allocator,
        json,
        .{},
    );
    defer parsed.deinit();
    for (parsed.value) |todo| {
        const text: []const u8 = try allocator.dupe(u8, todo.text);
        try list.append(allocator, .{ .text = text });
    }
}

fn save_todos(file_name: []const u8, list: *ArrayList(Todo)) !void {
    const global_single_threaded = Io.Threaded.global_single_threaded;
    const file = try Io.Dir.createFile(
        .cwd(),
        global_single_threaded.io(),
        file_name,
        .{ .read = true },
    );
    defer file.close(global_single_threaded.io());
    var buffer: [1024]u8 = undefined;
    var writer = file.writer(global_single_threaded.io(), &buffer);
    try std.json.Stringify.value(list.items, .{}, &writer.interface);
    try writer.interface.flush();
}

// -- Internal -- //
fn read_line(allocator: Allocator) ![]const u8 {
    var buffer: [1024]u8 = undefined;
    var reader: Io.File.Reader = .init(
        .stdin(),
        Io.Threaded.global_single_threaded.io(),
        &buffer,
    );
    const line = try reader.interface.takeDelimiterExclusive('\n');
    return try allocator.dupe(u8, line);
}

fn print_line(comptime fmt: []const u8, args: anytype) !void {
    var buffer: [1024]u8 = undefined;
    var writer: Io.File.Writer = .init(
        .stdout(),
        Io.Threaded.global_single_threaded.io(),
        &buffer,
    );
    _ = try writer.interface.print(fmt ++ "\n", args);
    try writer.flush();
}
