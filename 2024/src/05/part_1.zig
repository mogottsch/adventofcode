const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    const updates = input.updates;

    var valid_updates = try std.ArrayList([]u64).initCapacity(allocator, updates.len);
    defer valid_updates.deinit();

    for (updates) |update| {
        if (try isValidUpdate(allocator, update, input.rules)) {
            try valid_updates.append(update);
        }
    }

    const sum = sumMiddlePages(valid_updates.items);

    return sum;
}

fn getMiddlePage(update: []const u64) !u64 {
    std.debug.assert(update.len % 2 == 1);
    return update[update.len / 2];
}

pub fn sumMiddlePages(updates: [][]const u64) !u64 {
    var sum: u64 = 0;
    for (updates) |update| {
        sum += try getMiddlePage(update);
    }
    return sum;
}

pub fn isValidUpdate(
    allocator: std.mem.Allocator,
    update: []const u64,
    rules: std.AutoHashMap(u64, []u64),
) !bool {
    var past_pages = std.AutoHashMap(u64, bool).init(allocator);
    defer past_pages.deinit();

    for (update) |page| {
        if (rules.get(page)) |rights| {
            for (rights) |right| {
                if (past_pages.get(right) != null) {
                    return false;
                }
            }
        }
        try past_pages.put(page, true);
    }
    return true;
}
