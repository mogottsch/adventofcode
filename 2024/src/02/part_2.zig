const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    var safe_reports: u64 = 0;

    for (input.reports) |report| {
        if (try isSafeWhenAnyLevelRemoved(allocator, report)) {
            safe_reports += 1;
        }
    }

    return safe_reports;
}

fn isSafeWhenAnyLevelRemoved(allocator: std.mem.Allocator, report: parse.Report) !bool {
    const diffs = try calculateDiffs(allocator, report);
    defer allocator.free(diffs);

    if (isSafe(diffs)) {
        return true;
    }

    const almost_valid_res = isAlmostSafe(diffs);
    if (!almost_valid_res.is_almost_valid) {
        return false;
    }
    const problematic_index = almost_valid_res.problematic_index;
    const new_diffs = try removeLevelFromDiffs(allocator, diffs, problematic_index);
    defer allocator.free(new_diffs.moved_to_previous);
    defer allocator.free(new_diffs.moved_to_next);

    if (isSafe(new_diffs.moved_to_previous) or isSafe(new_diffs.moved_to_next)) {
        return true;
    }
    return false;
}

fn calculateDiffs(allocator: std.mem.Allocator, report: parse.Report) ![]i32 {
    const readings = report.readings;
    const diffs = try allocator.alloc(i32, readings.len - 1);
    for (readings[0 .. readings.len - 1], readings[1..readings.len], diffs) |last, current, *diff| {
        diff.* = @as(i32, @intCast(current)) - @as(i32, @intCast(last));
    }
    return diffs;
}

fn isSafe(diffs: []i32) bool {
    if (diffs.len == 0) return true;

    const first_diff = diffs[0];
    const is_increasing = first_diff > 0;

    for (diffs) |diff| {
        if (is_increasing and diff <= 0) return false;
        if (!is_increasing and diff >= 0) return false;
        if (@abs(diff) > 3) return false;
    }

    return true;
}

const n_allowed_problematic_indices = 2;
fn isAlmostSafe(diffs: []i32) struct {
    is_almost_valid: bool,
    problematic_index: usize,
} {
    if (diffs.len <= 1) return .{ .is_almost_valid = true, .problematic_index = 0 };

    var problematic_count: u64 = 0;
    var problematic_index: usize = 0;
    // var direction: ?bool = null; // true for increasing, false for decreasing
    const majority_direction = if (getMajorityDirection(diffs)) |dir| dir else return .{ .is_almost_valid = false, .problematic_index = 0 };

    // var had_direction_change = false;

    for (diffs, 0..) |diff, i| {
        var is_problematic = false;
        if (diff == 0) {
            is_problematic = true;
        }

        const is_positive = diff > 0;
        if (majority_direction != is_positive) {
            is_problematic = true;
        }

        if (@abs(diff) > 3) {
            is_problematic = true;
        }

        if (is_problematic) {
            problematic_count += 1;
            problematic_index = i;
            if (problematic_count > n_allowed_problematic_indices) {
                return .{
                    .is_almost_valid = false,
                    .problematic_index = problematic_index,
                };
            }
        }
    }

    return .{
        .is_almost_valid = problematic_count <= n_allowed_problematic_indices,
        .problematic_index = problematic_index,
    };
}

fn getMajorityDirection(diffs: []i32) ?bool {
    var increasing_count: u64 = 0;
    var decreasing_count: u64 = 0;

    for (diffs) |diff| {
        if (diff > 0) {
            increasing_count += 1;
        } else if (diff < 0) {
            decreasing_count += 1;
        }
    }

    if (increasing_count > decreasing_count) {
        return true;
    } else if (decreasing_count > increasing_count) {
        return false;
    }

    return null;
}

fn removeLevelFromDiffs(
    allocator: std.mem.Allocator,
    diffs: []const i32,
    level: usize,
) !struct {
    moved_to_previous: []i32,
    moved_to_next: []i32,
} {
    const moved_to_previous = try allocator.alloc(i32, diffs.len - 1);
    const moved_to_next = try allocator.alloc(i32, diffs.len - 1);

    @memcpy(moved_to_previous[0..level], diffs[0..level]);
    @memcpy(moved_to_previous[level..], diffs[level + 1 ..]);
    @memcpy(moved_to_next[0..level], diffs[0..level]);
    @memcpy(moved_to_next[level..], diffs[level + 1 ..]);

    if (level > 0) {
        moved_to_previous[level - 1] += diffs[level];
    }

    if (level < diffs.len - 1) {
        moved_to_next[level] += diffs[level];
    }

    return .{
        .moved_to_previous = moved_to_previous,
        .moved_to_next = moved_to_next,
    };
}

test "removeLevelFromDiffs" {
    {
        const diffs = [_]i32{ 2, -1, 2, 1 };
        const result = try removeLevelFromDiffs(testing.allocator, diffs[0..], 0);
        defer testing.allocator.free(result.moved_to_previous);
        defer testing.allocator.free(result.moved_to_next);
        try testing.expectEqualSlices(i32, &[_]i32{ -1, 2, 1 }, result.moved_to_previous);
        try testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 1 }, result.moved_to_next);
    }
    {
        const diffs = [_]i32{ 2, -1, 2, 1 };
        const result = try removeLevelFromDiffs(testing.allocator, diffs[0..], 1);
        defer testing.allocator.free(result.moved_to_previous);
        defer testing.allocator.free(result.moved_to_next);
        try testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 1 }, result.moved_to_previous);
        try testing.expectEqualSlices(i32, &[_]i32{ 2, 1, 1 }, result.moved_to_next);
    }
    {
        const diffs = [_]i32{ 2, -1, 2, 1 };
        const result = try removeLevelFromDiffs(testing.allocator, diffs[0..], 3);
        defer testing.allocator.free(result.moved_to_previous);
        defer testing.allocator.free(result.moved_to_next);
        try testing.expectEqualSlices(i32, &[_]i32{ 2, -1, 3 }, result.moved_to_previous);
        try testing.expectEqualSlices(i32, &[_]i32{ 2, -1, 2 }, result.moved_to_next);
    }
}
