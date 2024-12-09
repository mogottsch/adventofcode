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

    while (right_index > 0) {
        while (disk[right_index] == EMTPY_CHAR) right_index -= 1;

        const block = getFileBlock(disk, right_index);

        var left_index = findEmptySpaceWithSize(
            disk,
            block.size,
            right_index,
        ) orelse {
            if (block.start_index == 0) return;
            right_index = block.start_index - 1;
            continue;
        };

        moveFileBlock(disk, block, left_index);

        left_index += block.size;
    }
}

fn findEmptySpaceWithSize(disk: []u64, size: usize, max_index: usize) ?usize {
    var i: usize = 0;
    var space: usize = 0;
    while (i < max_index) {
        if (disk[i] == EMTPY_CHAR) {
            space += 1;
            if (space == size) return i + 1 - size;
        } else {
            space = 0;
        }
        i += 1;
    }
    return null;
}

const Block = struct {
    start_index: usize,
    size: usize,
};

// gets the block of the file under the index, where the index is the last entry of the block
fn getFileBlock(disk: []u64, index: usize) Block {
    var i: usize = index;
    const file_id = disk[index];

    var start_reached = false;

    while (disk[i] == file_id) {
        i -= 1;
        if (i == 0) {
            start_reached = true;
            break;
        }
    }

    const offset: usize = if (start_reached) 0 else 1;
    const start_index = i + offset;
    return Block{ .start_index = start_index, .size = index + 1 - start_index };
}

fn moveFileBlock(disk: []u64, block: Block, start_index_empty_space: usize) void {
    const size = block.size;
    @memcpy(
        disk[start_index_empty_space .. start_index_empty_space + size],
        disk[block.start_index .. block.start_index + size],
    );
    @memset(disk[block.start_index .. block.start_index + size], EMTPY_CHAR);
}

pub fn calculateChecksum(disk: []u64) u64 {
    var i: usize = 0;
    var checksum: u64 = 0;

    while (i < disk.len) {
        if (disk[i] == EMTPY_CHAR) {
            i += 1;
            continue;
        }
        checksum += disk[i] * i;
        i += 1;
    }
    return checksum;
}

test "getFileBlock" {
    var disk = [_]u64{ 1, 2, 2, EMTPY_CHAR, EMTPY_CHAR, 3, 3, 4, 4, 4 };
    const index = 9;
    const expected = Block{ .start_index = 7, .size = 3 };
    const result = getFileBlock(&disk, index);
    try testing.expectEqual(result, expected);
}

test "getFileBlock- potential underflow" {
    var disk = [_]u64{ 1, 1, 1 };
    const index = 2;
    const expected = Block{ .start_index = 0, .size = 3 };
    const result = getFileBlock(&disk, index);
    try testing.expectEqual(result, expected);
}

test "moveFileBlock" {
    var disk = [_]u64{ 1, 2, 2, EMTPY_CHAR, EMTPY_CHAR, 3, 3 };
    const block = Block{ .start_index = 5, .size = 2 };
    const start_index_empty_space = 3;
    const expected = [_]u64{ 1, 2, 2, 3, 3, EMTPY_CHAR, EMTPY_CHAR };
    moveFileBlock(&disk, block, start_index_empty_space);
    try testing.expectEqualSlices(u64, &expected, &disk);
}

test "findEmptySpaceWithSizeSuccess" {
    var disk = [_]u64{ 1, 2, 2, EMTPY_CHAR, EMTPY_CHAR, 3, 3, 4, 4, 4 };
    const size = 2;
    const expected = 3;
    const result = findEmptySpaceWithSize(&disk, size, disk.len);
    try testing.expectEqual(result, expected);
}

test "findEmptySpaceWithSizeFail" {
    var disk = [_]u64{ 1, 2, 2, EMTPY_CHAR, EMTPY_CHAR, 3, 3, 4, 4, 4 };
    const size = 3;
    const expected = null;
    const result = findEmptySpaceWithSize(&disk, size, disk.len);
    try testing.expectEqual(result, expected);
}
