const std = @import("std");
const path = @import("common").path;
const log = std.log;
const regex = @import("regex");
const regex_utils = @import("common").regex;
const pretty = @import("pretty");

const Instruction = enum {
    Mul,
    Do,
    Dont,
};

pub const InstructionWithArgs = struct {
    // command: Instruction,
    a: u32,
    b: u32,
};

pub const Input = struct {
    instructions: []InstructionWithArgs,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Input) void {
        self.allocator.free(self.instructions);
    }
};

pub fn parse_file(allocator: std.mem.Allocator, filename: []const u8) !Input {
    const filepath = try path.buildPath(allocator, filename);
    defer allocator.free(filepath);
    const file = try std.fs.openFileAbsolute(filepath, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(content);

    std.mem.replaceScalar(u8, content, '\n', ' ');
    var pattern = try regex.Regex.compile(allocator, "mul\\((\\d+),(\\d+)\\)");
    defer pattern.deinit();

    var captures_collection = try regex_utils.captureAll(allocator, &pattern, content);
    defer captures_collection.deinit();

    var instructions = std.ArrayList(InstructionWithArgs).init(allocator);
    for (captures_collection.captures_slice) |captures| {
        const a_str = regex.Captures.sliceAt(&captures, 1) orelse unreachable;
        const b_str = regex.Captures.sliceAt(&captures, 2) orelse unreachable;

        const pair = InstructionWithArgs{
            .a = try std.fmt.parseInt(u32, a_str, 10),
            .b = try std.fmt.parseInt(u32, b_str, 10),
        };
        try instructions.append(pair);
    }

    return Input{ .instructions = try instructions.toOwnedSlice(), .allocator = allocator };
}

// fn captureAll(allocator: std.mem.Allocator, content: []u8) ![]InstructionWithArgs {
//
//     var pairs = std.ArrayList(InstructionWithArgs).init(allocator);
//     var start: usize = 0;
//     while (true) {
//         var captures = try re.captures(content[start..]) orelse break;
//         defer captures.deinit();
//
//         const a_str = regex.Captures.sliceAt(&captures, 1) orelse unreachable;
//         const b_str = regex.Captures.sliceAt(&captures, 2) orelse unreachable;
//
//         const pair = InstructionWithArgs{
//             .a = try std.fmt.parseInt(u32, a_str, 10),
//             .b = try std.fmt.parseInt(u32, b_str, 10),
//         };
//         try pairs.append(pair);
//
//         const bounds = regex.Captures.boundsAt(&captures, 0) orelse unreachable;
//         start += bounds.upper;
//     }
//     return try pairs.toOwnedSlice();
// }
