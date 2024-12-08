const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    _ = allocator;

    var total: u64 = 0;
    var is_enabled: bool = true;

    for (input.instructions) |instruction_with_args| {
        const command = instruction_with_args.command;
        switch (command) {
            parse.Instruction.Do => is_enabled = true,
            parse.Instruction.Dont => is_enabled = false,
            parse.Instruction.Mul => if (is_enabled) {
                total += instruction_with_args.a * instruction_with_args.b;
            },
        }
    }

    return total;
}
