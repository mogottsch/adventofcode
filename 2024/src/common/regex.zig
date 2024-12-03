const std = @import("std");
const regex = @import("regex");

pub const CapturesCollection = struct {
    captures_slice: []regex.Captures,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *CapturesCollection) void {
        for (self.captures_slice) |*captures| {
            captures.deinit();
        }
        self.allocator.free(self.captures_slice);
    }
};

pub fn captureAll(allocator: std.mem.Allocator, pattern: *regex.Regex, content: []u8) !CapturesCollection {
    var captures_list = std.ArrayList(regex.Captures).init(allocator);
    var start: usize = 0;
    while (true) {
        var captures = try pattern.captures(content[start..]) orelse break;

        try captures_list.append(captures);

        const bounds = regex.Captures.boundsAt(&captures, 0) orelse unreachable;
        start += bounds.upper;
    }
    const captures_slice = try captures_list.toOwnedSlice();
    const captures_collection = CapturesCollection{
        .captures_slice = captures_slice,
        .allocator = allocator,
    };
    return captures_collection;
}
