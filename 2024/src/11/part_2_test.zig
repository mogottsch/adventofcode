const std = @import("std");
const testing = std.testing;
const parse = @import("parse.zig");
const part_2 = @import("part_2.zig");


const REAL_ANSWER_2: u64 = 252442982856820;

test "part 2 real" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var input = try parse.parseFile(allocator, "input.txt");
    defer input.deinit();

    const result = part_2.run(allocator, input);
    try testing.expectEqual(REAL_ANSWER_2, result);
}
