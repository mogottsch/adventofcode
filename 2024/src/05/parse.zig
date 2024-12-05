const std = @import("std");
const path = @import("common").path;
const log = std.log;

pub const Input = struct {
    left_before_rights: std.AutoHashMap(u32, []u32),
    updates: [][]u32,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Input) void {
        var iter = self.left_before_rights.valueIterator();
        while (iter.next()) |value| {
            self.allocator.free(value.*);
        }
        self.left_before_rights.deinit();

        for (self.updates) |update| {
            self.allocator.free(update);
        }
        self.allocator.free(self.updates);
    }
};

pub fn parse_file(allocator: std.mem.Allocator, filename: []const u8) !Input {
    const filepath = try path.buildPath(allocator, filename);
    defer allocator.free(filepath);
    const file = try std.fs.openFileAbsolute(filepath, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(content);

    var section_iter = std.mem.splitSequence(u8, content, "\n\n");
    const rule_section = section_iter.next().?;
    const update_section = section_iter.next().?;

    var rules = try parse_rules(allocator, rule_section);
    errdefer rules.deinit();

    const updates = try parse_updates(allocator, update_section[0 .. update_section.len - 1]);
    errdefer {
        for (updates) |update| {
            allocator.free(update);
        }
        allocator.free(updates);
    }

    return Input{ .left_before_rights = rules, .updates = updates, .allocator = allocator };
}

pub fn parse_rules(allocator: std.mem.Allocator, rules: []const u8) !std.AutoHashMap(u32, []u32) {
    var result = std.AutoHashMap(u32, std.ArrayList(u32)).init(allocator);
    defer result.deinit();

    var line_iter = std.mem.splitSequence(u8, rules, "\n");
    while (line_iter.next()) |line| {
        var parts = std.mem.splitSequence(u8, line, "|");
        const left = try std.fmt.parseUnsigned(u32, parts.next().?, 10);
        const new_right = try std.fmt.parseUnsigned(u32, parts.next().?, 10);

        var gop = try result.getOrPut(left);
        if (!gop.found_existing) {
            gop.value_ptr.* = std.ArrayList(u32).init(allocator);
        }
        try gop.value_ptr.append(new_right);
    }

    var final_result = std.AutoHashMap(u32, []u32).init(allocator);
    errdefer {
        var iter = final_result.valueIterator();
        while (iter.next()) |value| {
            allocator.free(value.*);
        }
        final_result.deinit();
    }

    var iter = result.iterator();
    while (iter.next()) |entry| {
        const key = entry.key_ptr.*;
        const value = try entry.value_ptr.*.toOwnedSlice();
        try final_result.put(key, value);
    }

    return final_result;
}

pub fn parse_updates(allocator: std.mem.Allocator, updates: []const u8) ![][]u32 {
    var result = std.ArrayList([]u32).init(allocator);
    errdefer {
        for (result.items) |item| {
            allocator.free(item);
        }
        result.deinit();
    }

    var line_iter = std.mem.splitSequence(u8, updates, "\n");
    while (line_iter.next()) |line| {
        var parts = std.mem.splitSequence(u8, line, ",");
        var update = std.ArrayList(u32).init(allocator);
        errdefer update.deinit();

        while (parts.next()) |part| {
            const number = std.fmt.parseUnsigned(u32, part, 10) catch |err| {
                log.err("Failed to parse number: {any}\n", .{part});
                return err;
            };
            try update.append(number);
        }
        try result.append(try update.toOwnedSlice());
    }

    return result.toOwnedSlice();
}
