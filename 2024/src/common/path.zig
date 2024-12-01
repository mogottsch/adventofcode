const std = @import("std");
const config = @import("config");

pub fn buildPath(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    const day = config.DAY;
    var buffer: [10]u8 = undefined;
    const day_str = try std.fmt.bufPrint(&buffer, "{:0>2}", .{day});

    const full_relative_path = try std.fs.path.join(allocator, &.{ "src", day_str, "data", path });
    defer allocator.free(full_relative_path);

    const cwd_path = try std.fs.cwd().realpathAlloc(allocator, ".");
    defer allocator.free(cwd_path);

    const absolute_path = try std.fs.path.resolve(allocator, &.{ cwd_path, full_relative_path });
    return absolute_path;
}

pub fn isValidPath(path: []const u8) !bool {
    std.fs.accessAbsolute(path, .{}) catch return false;
    return true;
}
