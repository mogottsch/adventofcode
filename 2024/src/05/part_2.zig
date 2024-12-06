const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const debug = @import("common").debug;
const part_1 = @import("part_1.zig");

const Rules = struct {
    map: std.AutoHashMap(u32, []u32),
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Rules) void {
        var it = self.map.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.value_ptr.*);
        }
        self.map.deinit();
    }
};

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u32 {
    const updates = input.updates;

    var invalid_updates = try std.ArrayList([]u32).initCapacity(allocator, updates.len);
    defer invalid_updates.deinit();

    for (updates) |update| {
        if (!try part_1.isValidUpdate(allocator, update, input.rules)) {
            try invalid_updates.append(update);
        }
    }

    for (invalid_updates.items) |update| {
        const original_rules = input.rules;
        var updated_rules = try removeUnusedRules(allocator, original_rules, update);
        defer updated_rules.deinit();
        var expanded_rules = try expandRulesTransitive(allocator, updated_rules.map);
        defer expanded_rules.deinit();
        try fixUpdate(allocator, update, expanded_rules.map);
    }

    const sum = part_1.sumMiddlePages(invalid_updates.items);

    return sum;
}

// removes rules that don't exist in the update, as they might cause to deduct wrong rules
// e.g. if A -> B, B -> C, C -> D, we deduct A -> D, but if B is not in the update, we should not deduct A -> D
fn removeUnusedRules(
    allocator: std.mem.Allocator,
    left_before_rights: std.AutoHashMap(u32, []u32),
    update: []u32,
) !Rules {
    var used_pages = std.AutoHashMap(u32, void).init(allocator);
    defer used_pages.deinit();
    for (update) |page| {
        try used_pages.put(page, {});
    }

    var result = std.AutoHashMap(u32, []u32).init(allocator);

    var it = left_before_rights.iterator();
    while (it.next()) |entry| {
        const left = entry.key_ptr.*;
        const rights = entry.value_ptr.*;
        if (used_pages.get(left) == null) {
            continue;
        }

        var count: usize = 0;
        for (rights) |right| {
            if (used_pages.get(right) != null) {
                count += 1;
            }
        }

        if (count > 0) {
            var new_rights = try allocator.alloc(u32, count);
            var i: usize = 0;
            for (rights) |right| {
                if (used_pages.get(right) != null) {
                    new_rights[i] = right;
                    i += 1;
                }
            }
            try result.put(left, new_rights);
        }
    }
    return Rules{
        .map = result,
        .allocator = allocator,
    };
}

// expands rules transitive, e.g. if A -> B, B -> C, we add A -> C
fn expandRulesTransitive(
    allocator: std.mem.Allocator,
    left_before_rights: std.AutoHashMap(u32, []u32),
) !Rules {
    var result = std.AutoHashMap(u32, []u32).init(allocator);

    var it = left_before_rights.iterator();
    while (it.next()) |entry| {
        const rights = try allocator.dupe(u32, entry.value_ptr.*);
        try result.put(entry.key_ptr.*, rights);
    }

    var changed = true;
    while (changed) {
        changed = false;

        var updates = std.ArrayList(struct { key: u32, value: []u32 }).init(allocator);
        defer updates.deinit();

        var outer_it = result.iterator();
        while (outer_it.next()) |entry| {
            const left = entry.key_ptr.*;
            const direct_rights = entry.value_ptr.*;

            for (direct_rights) |right| {
                if (result.get(right)) |indirect_rights| {
                    const new_rights = try addUniqueRights(allocator, direct_rights, indirect_rights);
                    if (new_rights.len > direct_rights.len) {
                        try updates.append(.{ .key = left, .value = new_rights });
                        changed = true;
                    } else {
                        allocator.free(new_rights);
                    }
                }
            }
        }

        for (updates.items) |update| {
            if (result.get(update.key)) |old_rights| {
                allocator.free(old_rights);
            }
            try result.put(update.key, update.value);
        }
    }

    return Rules{
        .map = result,
        .allocator = allocator,
    };
}

fn addUniqueRights(allocator: std.mem.Allocator, current: []u32, to_add: []u32) ![]u32 {
    var set = std.AutoHashMap(u32, void).init(allocator);
    defer set.deinit();

    for (current) |value| {
        try set.put(value, {});
    }

    for (to_add) |value| {
        try set.put(value, {});
    }

    var result = try allocator.alloc(u32, set.count());
    var i: usize = 0;
    var it = set.keyIterator();
    while (it.next()) |key| {
        result[i] = key.*;
        i += 1;
    }

    return result;
}

fn fixUpdate(
    allocator: std.mem.Allocator,
    update: []u32,
    left_before_rights: std.AutoHashMap(u32, []u32),
) !void {
    var changes_made = true;
    while (changes_made) {
        changes_made = false;
        var past_pages = std.AutoHashMap(u32, bool).init(allocator);
        defer past_pages.deinit();

        var right_index: usize = 0;
        while (right_index < update.len) {
            const page = update[right_index];
            if (left_before_rights.get(page)) |rights| {
                var min_left_index: usize = std.math.maxInt(usize);
                for (rights) |right| {
                    if (past_pages.get(right) != null) {
                        const left_index = findIndex(update, right);
                        min_left_index = @min(min_left_index, left_index);
                    }
                }
                if (min_left_index != std.math.maxInt(usize)) {
                    bubbleUp(update, min_left_index, right_index);
                    changes_made = true;
                    break;
                }
            }
            try past_pages.put(page, true);
            right_index += 1;
        }
    }
}

fn findIndex(update: []u32, value: u32) usize {
    var i: usize = 0;
    while (i < update.len) {
        if (update[i] == value) {
            return i;
        }
        i += 1;
    }
    return std.math.maxInt(usize);
}

fn bubbleUp(update: []u32, left_index: usize, right_index: usize) void {
    const value = update[right_index];
    var i = right_index;
    while (i > left_index) {
        update[i] = update[i - 1];
        i -= 1;
    }
    update[left_index] = value;
}
