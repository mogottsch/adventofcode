const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    _ = allocator;
    var sum: u64 = 0;

    for (input.equations) |equation| {
        const solvable = checkEquationSolvable(equation.left, 0, equation.right);
        if (solvable) {
            sum += equation.left;
        }
    }

    return sum;
}

fn checkEquationSolvable(left: u64, current: u64, right: []u64) bool {
    if (right.len == 0) {
        return left == current;
    }

    const next = right[0];

    return checkEquationSolvable(left, current + next, right[1..]) or
        checkEquationSolvable(left, current * next, right[1..]) or
        checkEquationSolvable(left, concatNumbers(current, next), right[1..]);
}

// 5, 62 -> 562
fn concatNumbers(left: u64, right: u64) u64 {
    // std.debug.print("left: {}, right: {}\n", .{ left, right });
    var temp = right;
    if (temp == 0) {
        return left * 10;
    }
    var multiplier: u64 = 1;
    while (temp > 0) : (temp /= 10) {
        multiplier *= 10;
    }
    // std.debug.print("multiplier: {}\n", .{multiplier});
    return left * multiplier + right;
}

test "concatNumbers" {
    try std.testing.expectEqual(@as(u64, 123456), concatNumbers(123, 456));
    try std.testing.expectEqual(@as(u64, 1230), concatNumbers(123, 0));
    try std.testing.expectEqual(@as(u64, 11), concatNumbers(1, 1));
    try std.testing.expectEqual(@as(u64, 50), concatNumbers(5, 0));
    try std.testing.expectEqual(@as(u64, 12345), concatNumbers(1, 2345));
    try std.testing.expectEqual(@as(u64, 9999999), concatNumbers(999, 9999));
}
