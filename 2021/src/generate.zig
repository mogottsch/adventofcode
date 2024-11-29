const std = @import("std");

const main_file_name = "main.zig";
const parse_file_name = "parse.zig";
const part_1_file_name = "part_1.zig";
const part_2_file_name = "part_2.zig";

const file_names = [_][]const u8{
    main_file_name,
    parse_file_name,
    part_1_file_name,
    part_2_file_name,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var args = std.process.args();
    _ = args.skip();
    const day_arg = args.next();
    if (day_arg == null) {
        std.debug.print("Please provide a day number\n", .{});
        return error.MissingArgument;
    }

    const day = try std.fmt.parseInt(u32, day_arg.?, 10);

    std.debug.print("Generating day {d}\n", .{day});

    var buffer: [10]u8 = undefined;
    const output_dir_path = try std.fmt.bufPrint(&buffer, "src/{:0>2}", .{day});

    std.debug.print("Writing to {s}\n", .{output_dir_path});

    // create the directory if it doesn't exist
    const cwd = std.fs.cwd();
    try cwd.makeDir(output_dir_path);

    for (file_names) |file_name| {
        const output_path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ output_dir_path, file_name });
        defer allocator.free(output_path);

        // Create the file
        var file = try cwd.createFile(output_path, .{});
        defer file.close();

        // Generate content for the specific day
        const content = try std.fmt.allocPrint(allocator,
            \\const std = @import("std");
            \\
            \\pub fn main() !void {{
            \\    std.debug.print("Day {d} solution", .{{{d}}});
            \\}}
        , .{ day, day });
        defer allocator.free(content);

        // Write the content to the file
        try file.writeAll(content);

        std.debug.print("Generated source file at {s}\n", .{output_path});
    }
}
