const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;

pub fn run(_: std.mem.Allocator, input: parse.Input) !u32 {
    var safe_reports: u32 = 0;
    for (input.reports) |report| {
        if (isSafe(report)) {
            safe_reports += 1;
        }
    }
    return safe_reports;
}

fn isSafe(report: parse.Report) bool {
    var was_increasing: ?bool = null;

    const readings = report.readings;

    for (readings[0 .. readings.len - 1], readings[1..readings.len]) |last, current| {
        // check trend
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
