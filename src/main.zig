const std = @import("std");
const DateTime = @import("datetime.zig").DateTime;

pub fn main(init: std.process.Init) !void {
    var datetime: DateTime = .now(init.io);
    datetime = datetime.add(.day, 2);
    datetime = datetime.add(.month, 5);
    const component = datetime.component();
    std.debug.print("{d}\n", .{datetime.timestamp.toSeconds()});
    std.debug.print("{d}-{d}-{d} {d}:{d}:{d}\n", .{
        component.year,
        component.month,
        component.day,
        component.hour,
        component.minute,
        component.second,
    });
    const timestamp = component.timestamp();
    std.debug.print("{d}\n", .{timestamp.toSeconds()});
    std.debug.print("{s}\n", .{datetime.iso_date()});
    std.debug.print("{s}\n", .{datetime.iso_datetime()});
}
