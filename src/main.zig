const std = @import("std");
const stdout = std.debug.print;

pub fn main() !void {
    // 1. create allocator
    // 2. try to allocate 5
    // 3. free memory
    // 4. update value
    // 5. print result

    const pa = std.heap.page_allocator;
    var list = try pa.alloc(i32, 5);
    defer pa.free(list);
    list[0] = 42;
    stdout("The answer is {d}! \n", .{list[0]});

    var gpa = std.heap.DebugAllocator(.{}).init;
    const allocator = gpa.allocator();
    const bytes = try allocator.dupe(u8, "Hello zig allocator !");
    defer allocator.free(bytes);
    stdout("{s}\n", .{bytes});
}
