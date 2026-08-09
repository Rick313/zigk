const std = @import("std");
const Io = std.Io;
const Timestamp = Io.Timestamp;

pub const Granularity = enum { year, month, day, hour, minute, second };

pub const DateTime = struct {
    timestamp: Timestamp = .{ .nanoseconds = 0 },

    pub fn now(io: Io) DateTime {
        return .{ .timestamp = .now(io, .real) };
    }

    pub fn add(self: *DateTime, granularity: Granularity, n: u32) DateTime {
        return self.mofidy(granularity, @intCast(n));
    }

    pub fn sub(self: *DateTime, granularity: Granularity, n: u32) DateTime {
        return self.mofidy(granularity, @as(i32, @intCast(n)) * -1);
    }

    pub fn component(self: *DateTime) DateComponent {
        const epoch = self.timestamp.toSeconds();
        var total_seconds = @rem(epoch, std.time.s_per_day);
        if (total_seconds < 0) total_seconds += std.time.s_per_day;
        const hour = @divFloor(total_seconds, std.time.s_per_hour);
        const minute = @divFloor(@rem(total_seconds, std.time.s_per_hour), std.time.s_per_min);
        const second = @rem(total_seconds, std.time.s_per_min);

        const days_since_epoch = @divFloor(epoch, std.time.s_per_day);
        const z = days_since_epoch + 719_468; // num days between 0000-03-01 & 1970-01-01

        const era = @divFloor(if (z >= 0) z else z - 146_096, 146_097);
        const day_of_era = z - era * 146_097;
        // zig fmt: off
        const year_of_era = 
            @divFloor(
                day_of_era 
                - @divFloor(day_of_era, 1_460) 
                + @divFloor(day_of_era, 36_524) 
                - @divFloor(day_of_era, 146_000)
                , 365);
        var year = year_of_era + era * 400;
        // zig fmt: on

        const day_of_year = day_of_era - (365 * year_of_era + @divFloor(year_of_era, 4) - @divFloor(year_of_era, 100));
        var month = @divFloor((5 * day_of_year + 2), 153);

        const day = day_of_year - @divFloor((153 * month + 2), 5) + 1;

        month = if (month < 10) month + 3 else month - 9;
        const correct: isize = if (month <= 2) 1 else 0;
        year = year + correct;

        return .{
            .year = @intCast(year),
            .month = @intCast(month),
            .day = @intCast(day),
            .hour = @intCast(hour),
            .minute = @intCast(minute),
            .second = @intCast(second),
        };
    }

    pub fn iso_date(self: *DateTime) [10]u8 {
        return self.component().iso_date();
    }

    pub fn iso_datetime(self: *DateTime) [20]u8 {
        return self.component().iso_datetime();
    }

    fn mofidy(self: *DateTime, granularity: Granularity, n: i32) DateTime {
        const current = self.timestamp.toSeconds();

        const seconds = switch (granularity) {
            Granularity.second => current + n,
            Granularity.minute => current + (n * std.time.s_per_min),
            Granularity.hour => current + (n * std.time.s_per_hour),
            Granularity.day => current + (n * std.time.s_per_day),
            Granularity.month => {
                var cpm = self.component();

                const total_months = @as(i32, @intCast(cpm.year * 12)) + @as(i32, @intCast(cpm.month - 1)) + @as(i32, @intCast(n));
                const year = @divFloor(total_months, 12);
                var month = @rem(total_months, 12) + 1;
                if (month <= 0) month += 12;
                const is_leap = @mod(year, 4) == 0 or @mod(year, 100) != 0 or 0 == @mod(year, 400);
                const months_days: [12]u36 = .{ 31, if (is_leap) 29 else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
                const day = @min(cpm.day, months_days[@as(usize, @intCast(month - 1))]);
                cpm.year = @intCast(year);
                cpm.month = @intCast(month);
                cpm.day = day;
                return cpm.datetime();
            },
            Granularity.year => {
                var cpm = self.component();
                const year: i32 = @as(i32, @intCast(cpm.year)) + @as(i32, @intCast(n));
                const is_leap = @mod(year, 4) == 0 or @mod(year, 100) != 0 or 0 == @mod(year, 400);
                const day = if (cpm.month == 2 and cpm.day == 29 and !is_leap) 28 else cpm.day;
                cpm.year = @intCast(year);
                cpm.day = day;
                return cpm.datetime();
            },
        };
        return .{ .timestamp = .fromNanoseconds(seconds * std.time.ns_per_s) };
    }
};

pub const DateComponent = struct {
    year: u16 = 1970,
    month: u8 = 1,
    day: u8 = 1,
    hour: u8 = 0,
    minute: u8 = 0,
    second: u8 = 0,

    pub fn now(io: Io) DateComponent {
        const dt: DateTime = .{ .timestamp = .now(io, .real) };
        return dt.component();
    }

    pub fn timestamp(self: *const DateComponent) Timestamp {
        return self.datetime().timestamp;
    }

    pub fn datetime(self: *const DateComponent) DateTime {
        const _year: u32 = if (self.month <= 2) self.year - 1 else self.year;
        const _month: u32 = if (self.month <= 2) self.month + 9 else self.month - 3;

        const era = @divFloor((if (_year >= 0) _year else _year - 399), 400);
        const year_of_era = _year - era * 400;
        const day_of_year = @divFloor((153 * _month + 2), 5) + self.day - 1;
        const day_of_era = year_of_era * 365 + @divFloor(year_of_era, 4) - @divFloor(year_of_era, 100) + day_of_year;
        const day_since_epoch_origin = era * 146_097 + day_of_era;
        const total_days = day_since_epoch_origin - 719_468;
        // zig fmt: off
        const seconds: u32 = 
            (total_days * std.time.s_per_day) 
            + (@as(u16, @intCast(self.hour)) * std.time.s_per_hour) 
            + (@as(u16, @intCast(self.minute)) * std.time.s_per_min) 
            + self.second;
        // zig fmt: on
        return .{ .timestamp = .fromNanoseconds(@as(i96, @intCast(seconds)) * std.time.ns_per_s) };
    }

    fn iso_date(self: *const DateComponent) [10]u8 {
        var result: [10]u8 = undefined;
        _ = std.fmt.bufPrint(
            &result,
            "{d:0>4}-{d:0>2}-{d:0>2}",
            .{ self.year, self.month, self.day },
        ) catch unreachable;

        return result;
    }

    fn iso_datetime(self: *const DateComponent) [20]u8 {
        var result: [20]u8 = undefined;
        _ = std.fmt.bufPrint(
            &result,
            "{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}Z",
            .{ self.year, self.month, self.day, self.hour, self.minute, self.second },
        ) catch unreachable;

        return result;
    }
};
