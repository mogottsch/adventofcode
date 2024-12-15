const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");

const Robot = parse.Robot;
const Bounds = parse.Bounds;

const SIMULATE_SECONDS: u64 = 100;

const Quadrants = struct {
    quadrant_top_left: u64,
    quadrant_top_right: u64,
    quadrant_bottom_left: u64,
    quadrant_bottom_right: u64,
};

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    _ = allocator;

    const bounds = Bounds{ .max_x = 101, .max_y = 103 };

    for (input.robots) |*robot| {
        for (0..SIMULATE_SECONDS) |_| robot.move(bounds);
    }

    return calculateSafetyFactor(countQuadrants(input.robots, bounds));
}

fn countQuadrants(robots: []Robot, bounds: Bounds) Quadrants {
    var quadrant_top_left: u64 = 0;
    var quadrant_top_right: u64 = 0;
    var quadrant_bottom_left: u64 = 0;
    var quadrant_bottom_right: u64 = 0;

    const x_bounds = calculateQuadrantBoundaries(bounds.max_x);
    const y_bounds = calculateQuadrantBoundaries(bounds.max_y);

    for (robots) |robot| {
        if (robot.x <= x_bounds.start and robot.y <= y_bounds.start) {
            quadrant_top_left += 1;
        } else if (robot.x >= x_bounds.end and robot.y <= y_bounds.start) {
            quadrant_top_right += 1;
        } else if (robot.x <= x_bounds.start and robot.y >= y_bounds.end) {
            quadrant_bottom_left += 1;
        } else if (robot.x >= x_bounds.end and robot.y >= y_bounds.end) {
            quadrant_bottom_right += 1;
        }
    }

    return Quadrants{
        .quadrant_top_left = quadrant_top_left,
        .quadrant_top_right = quadrant_top_right,
        .quadrant_bottom_left = quadrant_bottom_left,
        .quadrant_bottom_right = quadrant_bottom_right,
    };
}

fn calculateQuadrantBoundaries(max: i64) struct { start: i64, end: i64 } {
    const is_even = @rem(max, 2) == 0;
    const mid = @divTrunc(max, 2);

    return if (is_even) .{
        .start = mid - 1,
        .end = mid,
    } else .{
        .start = mid - 1,
        .end = mid + 1,
    };
}

fn calculateSafetyFactor(quadrants: Quadrants) u64 {
    return quadrants.quadrant_top_left *
        quadrants.quadrant_top_right *
        quadrants.quadrant_bottom_left *
        quadrants.quadrant_bottom_right;
}

pub fn printRobots(robots: []Robot, bounds: Bounds) void {
    std.debug.print("\n", .{});
    var y: i32 = 0;
    while (y <= bounds.max_y) : (y += 1) {
        var x: i32 = 0;
        while (x <= bounds.max_x) : (x += 1) {
            var count: u8 = 0;
            for (robots) |robot| {
                if (robot.x == x and robot.y == y) {
                    count += 1;
                }
            }
            if (count == 0) {
                std.debug.print(".", .{});
            } else {
                std.debug.print("{d}", .{count});
            }
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}

test "calculateQuadrantBoundaries" {
    // Test even numbers
    {
        const result = calculateQuadrantBoundaries(4);
        try testing.expectEqual(1, result.start);
        try testing.expectEqual(2, result.end);
    }

    // Test odd numbers
    {
        const result = calculateQuadrantBoundaries(5);
        try testing.expectEqual(1, result.start);
        try testing.expectEqual(3, result.end);
    }
}
