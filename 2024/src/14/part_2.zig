const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const part_1 = @import("part_1.zig");

const Bounds = parse.Bounds;
const Robot = parse.Robot;

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    const bounds = Bounds{ .max_x = 101, .max_y = 103 };

    // const file = try std.fs.cwd().createFile("robot_patterns.txt", .{});
    // defer file.close();
    //
    // const writer = file.writer();
    // var buffered_writer = std.io.bufferedWriter(writer);
    // const buf_writer = buffered_writer.writer();

    var seconds: u64 = 0;

    while (true) {
        seconds += 1;
        for (input.robots) |*robot| {
            robot.move(bounds);
        }

        if (hasChristmasTreePattern(allocator, input.robots, bounds)) {
            // try writeRobotsToFile(input.robots, bounds, buf_writer, seconds);
            break;
        }
    }

    // try buffered_writer.flush();

    return seconds;
}

fn hasChristmasTreePattern(allocator: std.mem.Allocator, robots: []Robot, bounds: Bounds) bool {
    const width = @as(usize, @intCast(bounds.max_x + 1));
    const height = @as(usize, @intCast(bounds.max_y + 1));
    var grid = allocator.alloc(bool, width * height) catch unreachable;
    defer allocator.free(grid);
    @memset(grid, false);

    for (robots) |robot| {
        if (robot.x >= 0 and robot.x <= bounds.max_x and
            robot.y >= 0 and robot.y <= bounds.max_y)
        {
            const idx = @as(usize, @intCast(robot.y)) * width + @as(usize, @intCast(robot.x));
            grid[idx] = true;
        }
    }

    var y: usize = 0;
    while (y < height) : (y += 1) {
        var consecutive: u8 = 0;
        var x: usize = 0;
        while (x < width) : (x += 1) {
            if (grid[y * width + x]) {
                consecutive += 1;
                if (consecutive == 16) return true;
            } else {
                consecutive = 0;
            }
        }
    }

    return false;
}

pub fn writeRobotsToFile(robots: []Robot, bounds: Bounds, writer: anytype, second: u64) !void {
    try writer.print("\nSecond {d}:\n", .{second});

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
            try writer.writeByte(if (count == 0) '.' else count + '0');
        }
        try writer.writeByte('\n');
    }
    try writer.writeByte('\n');
}
