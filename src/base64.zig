const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Base64 = struct {
    const table: *const [64]u8 = upper ++ lower ++ numbers;
    const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const lower = "abcdefghijklmnopqrstuvwxyz";
    const numbers = "0123456789+/";

    pub fn encode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return "";
        const len = try _calc_encode_length(input);
        var output = try allocator.alloc(u8, len);
        var buffer: [3]u8 = .{0} ** 3;
        var count: usize = 0;
        var iout: usize = 0;

        for (input) |byte| {
            buffer[count] = byte;
            count += 1;
            if (count != 3) continue;
            output[iout] = _char_at(buffer[0] >> 2);
            output[iout + 1] = _char_at((buffer[0] & 0x03) << 4) + (buffer[1] >> 4);
            output[iout + 2] = _char_at((buffer[1] & 0x0f) << 2) + (buffer[2] >> 6);
            output[iout + 3] = _char_at(buffer[2] & 0x3f);
            iout += 4;
            count = 0;
        }

        if (count == 1) {
            output[iout] = _char_at(buffer[0] >> 2);
            output[iout + 1] = _char_at((buffer[0] & 0x03) << 4);
            output[iout + 2] = '=';
            output[iout + 3] = '=';
        } else if (count == 2) {
            output[iout] = _char_at(buffer[0] >> 2);
            output[iout + 1] = _char_at(((buffer[0] & 0x03) << 4) + (buffer[1] >> 4));
            output[iout + 2] = _char_at((buffer[1] & 0x0f) << 2);
            output[iout + 3] = '=';
            iout += 4;
        }

        return output;
    }

    pub fn decode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return "";

        const len = try _calc_decode_length(input);
        var buffer: [4]u8 = .{0} ** 4;
        var count: usize = 0;
        var output_index: usize = 0;
        var output = try allocator.alloc(u8, len);

        for (input) |char| {
            buffer[count] = _char_index(char);
            count += 1;
            if (count != 4) continue;
            output[output_index] = (buffer[0] << 2) + (buffer[1] >> 4);
            if (buffer[2] != 64) output[output_index + 1] = (buffer[1] << 4) + (buffer[2] >> 2);
            if (buffer[3] != 64) output[output_index + 2] = (buffer[2] << 6) + buffer[3];
            output_index += 3;
            count = 0;
        }

        return output;
    }

    fn _char_index(char: u8) u8 {
        if (char == '=') return 64;
        var i: usize = 0;
        var output_index: u8 = 0;
        while (i < 64) : (i += 1) {
            if (_char_at(i) == char) return output_index;
            output_index += 1;
        }
        return output_index;
    }

    fn _char_at(index: usize) u8 {
        return table[index];
    }

    fn _calc_encode_length(input: []const u8) !usize {
        if (input.len < 3) return 4;
        const groups = try std.math.divCeil(usize, input.len, 3);
        return groups * 4;
    }

    fn _calc_decode_length(input: []const u8) !usize {
        if (input.len < 4) return 3;
        const groups = try std.math.divFloor(usize, input.len, 4);
        var multiple = groups * 3;
        var i = input.len - 1;
        while (i > 0) : (i -= 1) {
            if (input[i] != '=') return multiple;
            multiple -= 1;
        }
        return multiple;
    }
};
