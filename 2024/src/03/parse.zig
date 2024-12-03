const std = @import("std");
const path = @import("common").path;
const log = std.log;
const regex = @import("regex");
const regex_utils = @import("common").regex;
const pretty = @import("pretty");

pub const Instruction = enum {
    Mul,
    Do,
    Dont,

    pub fn fromString(s: []const u8) Instruction {
        if (std.mem.eql(u8, s, "mul")) {
            return Instruction.Mul;
        } else if (std.mem.eql(u8, s, "do")) {
            return Instruction.Do;
        } else if (std.mem.eql(u8, s, "don't")) {
            return Instruction.Dont;
        }
        log.err("Unknown instruction: {s}\n", .{s});
        unreachable;
    }
};

pub const InstructionWithArgs = struct {
    command: Instruction,
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
    var pattern = try regex.Regex.compile(allocator, "(mul)\\((\\d+),(\\d+)\\)|(do)\\(\\)|(don't)\\(\\)");
    defer pattern.deinit();

    var captures_collection = try regex_utils.captureAll(allocator, &pattern, content);
    defer captures_collection.deinit();

    var instructions = std.ArrayList(InstructionWithArgs).init(allocator);
    for (captures_collection.captures_slice) |captures| {
        // std.debug.print("captures len {d}\n", .{captures.slots.len / 2});
        // std.debug.print("match: {s}\n", .{total_str});

        const instruction_raw_full = regex.Captures.sliceAt(&captures, 0) orelse unreachable;
        var instruction_raw_full_split_iter = std.mem.splitScalar(u8, instruction_raw_full, '(');
        const instruction_raw = instruction_raw_full_split_iter.next() orelse unreachable;

        // std.debug.print("instruction: {s}\n", .{instruction_raw});
        const instruction = Instruction.fromString(instruction_raw);

        const a_str = if (instruction == Instruction.Mul) (regex.Captures.sliceAt(&captures, 2) orelse "0") else "0";
        const b_str = if (instruction == Instruction.Mul) (regex.Captures.sliceAt(&captures, 3) orelse "0") else "0";
        // std.debug.print("a: {s}, b: {s}\n", .{ a_str, b_str });

        const pair = InstructionWithArgs{
            .a = try std.fmt.parseInt(u32, a_str, 10),
            .b = try std.fmt.parseInt(u32, b_str, 10),
            .command = instruction,
        };
        try instructions.append(pair);
    }

    return Input{ .instructions = try instructions.toOwnedSlice(), .allocator = allocator };
}
