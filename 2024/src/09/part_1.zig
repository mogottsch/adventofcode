const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");

const EMTPY_CHAR = parse.EMTPY_CHAR;

pub fn run(_: std.mem.Allocator, input: parse.Input) !u64 {
    const disk = input.disk;

    reorderDisk(disk);

    return calculateChecksum(disk);
}

fn reorderDisk(disk: []u64) void {
    var right_index: usize = disk.len - 1;
    var left_index: usize = 0;

    while (left_index < right_index) {
        while (disk[left_index] != EMTPY_CHAR) left_index += 1;
        while (disk[right_index] == EMTPY_CHAR) right_index -= 1;

        if (left_index >= right_index) break;

        disk[left_index] = disk[right_index];
        disk[right_index] = EMTPY_CHAR;
    }
}

fn calculateChecksum(disk: []u64) u64 {
    var i: usize = 0;
    var checksum: u64 = 0;

    while (true) {
        if (disk[i] == EMTPY_CHAR) break;
        checksum += disk[i] * i;
        i += 1;
    }
    return checksum;
}
