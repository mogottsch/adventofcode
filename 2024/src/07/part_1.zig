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
        checkEquationSolvable(left, current * next, right[1..]);
}
