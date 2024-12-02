const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u32 {
    var safe_reports: u32 = 0;
    for (input.reports) |report| {
        if (try isSafeWhenAnyLevelRemoved(allocator, report)) {
            safe_reports += 1;
        }
    }

    return safe_reports;
}

// brute force for now
fn isSafeWhenAnyLevelRemoved(allocator: std.mem.Allocator, report: parse.Report) !bool {
    for (0..report.readings.len) |reading_idx| {
        const new_report = try removeLevel(allocator, report, reading_idx);
        defer allocator.free(new_report.readings);
        if (isSafe(new_report)) {
            return true;
        }
    }
    return false;
}

fn removeLevel(
    allocator: std.mem.Allocator,
    report: parse.Report,
    level: usize,
) !parse.Report {
    const readings = report.readings;
    const new_readings = try allocator.alloc(u32, readings.len - 1);
    @memcpy(new_readings[0..level], readings[0..level]);
    @memcpy(new_readings[level..], readings[level + 1 ..]);

    return parse.Report{ .readings = new_readings, .allocator = allocator };
}

fn isSafe(report: parse.Report) bool {
    var was_increasing: ?bool = null;

    const readings = report.readings;

    for (readings[0 .. readings.len - 1], readings[1..readings.len]) |last, current| {
        const is_increasing = last < current;
        if (was_increasing != null and was_increasing != is_increasing) {
            return false;
        }
        was_increasing = is_increasing;

        const diff = @abs(@as(i32, @intCast(last)) - @as(i32, @intCast(current)));
        if (diff == 0 or diff > 3) {
            return false;
        }
    }
    return true;
}
