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

    var best_cost: i64 = std.math.maxInt(i64);
    var best_solution: Solution = undefined;
    var found = false;

    const search_range: i64 = 200;
    var a: i64 = 0;
    while (a <= search_range) : (a += 1) {
        if (@rem(px - a * ax, bx) != 0) continue;
        const b = @divExact(px - a * ax, bx);

        const term1 = a * ay;
        const term2 = b * by;
        const sum = term1 + term2;

        if (sum != py) continue;

        const cost = 3 * a + b;
        if (cost < best_cost) {
            best_cost = cost;
            best_solution = .{ .a = a, .b = b, .cost = cost };
            found = true;
        }
    }

    return if (found) best_solution else null;
}

fn sumPrizes(prizes: []Solution) u64 {
    var sum: u64 = 0;
    for (prizes) |prize| {
        sum += @intCast(prize.cost);
    }
    return sum;
}
