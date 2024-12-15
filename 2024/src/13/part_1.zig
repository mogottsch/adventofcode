const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");

const System = parse.System;

const Solution = struct {
    a: i64,
    b: i64,
    cost: i64,
};

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    return try findAndSumPrizes(allocator, input);
}

pub fn findAndSumPrizes(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    var prizes = std.ArrayList(Solution).init(allocator);
    defer prizes.deinit();

    for (input.systems) |system| {
        const solution = solve(system);
        if (solution != null) {
            try prizes.append(solution.?);
        }
    }

    return sumPrizes(prizes.items);
}

pub fn solve(system: System) ?Solution {
    const ax: i64 = @intCast(system.a_x);
    const ay: i64 = @intCast(system.a_y);
    const bx: i64 = @intCast(system.b_x);
    const by: i64 = @intCast(system.b_y);
    const px: i64 = @intCast(system.p_x);
    const py: i64 = @intCast(system.p_y);
    // ax*a + bx*b = px
    // ay*a + by*b = py

    const det = ax * by - ay * bx;
    if (det == 0) return null; // lines are parallel

    // a = (px*by - py*bx) / det
    // b = (ax*py - ay*px) / det

    const a_num = px * by - py * bx;
    const b_num = ax * py - ay * px;

    if (@rem(a_num, det) != 0 or @rem(b_num, det) != 0) return null;

    const a = @divExact(a_num, det);
    const b = @divExact(b_num, det);

    if (a <= 0 or b <= 0) return null;

    return Solution{ .a = a, .b = b, .cost = 3 * a + b };
}

fn gcd_extended(a: i64, b: i64, x: *i64, y: *i64) i64 {
    if (a == 0) {
        x.* = 0;
        y.* = 1;
        return b;
    }

    var x1: i64 = undefined;
    var y1: i64 = undefined;
    const gcd = gcd_extended(@rem(b, a), a, &x1, &y1);

    x.* = y1 - @divTrunc(b, a) * x1;
    y.* = x1;

    return gcd;
}

fn sumPrizes(prizes: []Solution) u64 {
    var sum: u64 = 0;
    for (prizes) |prize| {
        sum += @intCast(prize.cost);
    }
    return sum;
}
