const std = @import("std");
const info = std.log.info;
const path = @import("path.zig");
const config = @import("config");

const ArgsParseError = error{
    MissingPart,
    MissingPath,
    WrongPart,
    PathDoesNotExist,
};

pub const Parts = enum { part_1, part_2 };

pub fn parseArgs() !struct {
    part: Parts,
    path: []const u8,
} {
    var args = std.process.args();
    _ = args.skip();

    const part_arg = args.next();
    if (part_arg == null) {
        return ArgsParseError.MissingPart;
    }

    const maybe_part = std.meta.stringToEnum(Parts, part_arg.?);
    if (maybe_part == null) {
        return ArgsParseError.WrongPart;
    }
    const part = maybe_part.?;

    const path_arg = args.next();
    if (path_arg == null) {
        return ArgsParseError.MissingPath;
    }

    const day = config.DAY;
    info("Day: {d}", .{day});
    const path_with_day = try path.buildPath(path_arg.?);
    const is_valid_path = try path.isValidPath(path_with_day);

    if (!is_valid_path) {
        return ArgsParseError.PathDoesNotExist;
    }

    return .{ .part = part, .path = path_arg.? };
}
