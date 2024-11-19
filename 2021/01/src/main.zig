const std = @import("std");
const testing = std.testing;
const info = std.log.info;

const ArgsParseError = error{
    MissingPart,
    MissingPath,
    WrongPart,
    PathDoesNotExist,
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var args = std.process.args();

    _ = args.skip();

    const partArg = args.next();
    if (partArg == null) {
        return ArgsParseError.MissingPart;
    }

    const Parts = enum { part_1, part_2 };
    const maybePart = std.meta.stringToEnum(Parts, partArg.?);

    if (maybePart == null) {
        return ArgsParseError.WrongPart;
    }
    const part = maybePart.?;

    const pathArg = args.next();
    if (pathArg == null) {
        return ArgsParseError.MissingPath;
    }

    if (!isValidPath(pathArg.?)) {
        return ArgsParseError.PathDoesNotExist;
    }

    const input = try parse_file(allocator, pathArg.?);
    defer allocator.free(input);

    var result: ?i32 = null;
    switch (part) {
        .part_1 => {
            info("Running part 1", .{});
            result = try part_1(input);
        },
        .part_2 => {
            info("Running part 2", .{});
            result = part_2(input);
        },
    }

    info("{d}", .{result.?});
}

fn isValidPath(path: []const u8) bool {
    std.fs.cwd().access(path, .{}) catch return false;
    return true;
}

pub fn parse_file(allocator: std.mem.Allocator, filepath: []const u8) ![]i32 {
    const file = try std.fs.cwd().openFile(filepath, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    var count: usize = 0;
    for (content) |c| {
        if (c == '\n') count += 1;
    }

    const numbers = try allocator.alloc(i32, count);

    var line_iterator = std.mem.splitScalar(u8, content[0 .. content.len - 1], '\n');
    var i: usize = 0;
    while (line_iterator.next()) |line| : (i += 1) {
        numbers[i] = try std.fmt.parseInt(i32, line, 10);
    }

    return numbers;
}

pub fn part_1(numbers: []i32) !i32 {
    var last_number: ?i32 = null;
    var n_increases: i32 = 0;
    for (numbers) |number| {
        if (last_number != null and number > last_number.?) {
            n_increases += 1;
        }
        last_number = number;
    }
    return n_increases;
}

const EXAMPLE_ANSWER_1: i32 = 7;

test "part 1" {
    const allocator = std.heap.page_allocator;
    const lines = try parse_file(allocator, "example_1.txt");
    defer allocator.free(lines);

    const result = part_1(lines);
    try testing.expectEqual(result, EXAMPLE_ANSWER_1);
}

pub fn part_2(numbers: []i32) i32 {
    const n_lines = numbers.len;
    if (n_lines < 4) {
        return 0;
    }

    var n_increases: i32 = 0;
    var last_sum: ?i32 = null;

    var i: usize = 2;
    while (i < n_lines) : (i += 1) {
        const sum = numbers[i] + numbers[i - 1] + numbers[i - 2];
        if (last_sum != null and sum > last_sum.?) {
            n_increases += 1;
        }
        last_sum = sum;
    }

    return n_increases;
}

const EXAMPLE_ANSWER_2: i32 = 5;

test "part 2" {
    const allocator = std.heap.page_allocator;
    const numbers = try parse_file(allocator, "example_2.txt");
    defer allocator.free(numbers);

    const result = part_2(numbers);
    try testing.expectEqual(result, EXAMPLE_ANSWER_2);
}
