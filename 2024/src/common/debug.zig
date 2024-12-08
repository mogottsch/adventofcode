const std = @import("std");

pub fn printHashMap(dict: anytype) void {
    std.debug.print("Dict{{\n", .{});
    var iter = dict.iterator();
    while (iter.next()) |entry| {
        std.debug.print("  {any}: {any}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
    std.debug.print("}}\n", .{});
}

pub fn printHashMapCharToArrayList(dict: anytype) void {
    std.debug.print("Dict{{\n", .{});
    var iter = dict.iterator();
    while (iter.next()) |entry| {
        std.debug.print("  {c}: [", .{entry.key_ptr.*});
        const list = entry.value_ptr.*;
        std.debug.print("{any}", .{list.items});
        std.debug.print("]\n", .{});
    }
    std.debug.print("}}\n", .{});
}
