const std = @import("std");
const mustache = @import("mustache");
const scrape = @import("scrape.zig");

const TemplatedFile = struct {
    index: u32,
    template_name: []const u8,
    output_name: []const u8,
};
const parse_template = TemplatedFile{ .index = 1, .template_name = "parse.zig.mustache", .output_name = "parse.zig" };
const main_template = TemplatedFile{ .index = 0, .template_name = "main.zig.mustache", .output_name = "main.zig" };
const part_1_template = TemplatedFile{ .index = 2, .template_name = "part_1.zig.mustache", .output_name = "part_1.zig" };
const part_2_template = TemplatedFile{ .index = 3, .template_name = "part_2.zig.mustache", .output_name = "part_2.zig" };
const templated_files = [_]TemplatedFile{
    main_template,
    parse_template,
    part_1_template,
    part_2_template,
};
const Context = struct {
    answer: ?i32,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const day = try parseDayFromArgs();
    std.debug.print("Generating day {d}\n", .{day});

    const day_data = try scrape.scrapeDay(allocator, 2021, day);
    defer day_data.deinit();
    std.debug.print(
        "Input: {s}\nPart 1 example input: {s}\nPart 2 example input: {s}\nPart 1 example answer: {d}\nPart 2 example answer: {d}\n",
        .{ day_data.input, day_data.part_1_example_input, day_data.part_2_example_input, day_data.part_1_example_answer, day_data.part_2_example_answer },
    );

    return error.Ok;

    // var buffer: [10]u8 = undefined;
    // const output_dir_path = try std.fmt.bufPrint(&buffer, "src/{:0>2}", .{day});
    // std.debug.print("Writing to {s}\n", .{output_dir_path});
    //
    // const cwd = std.fs.cwd();
    // try cwd.makeDir(output_dir_path);
    //
    // for (templated_files) |templated_file| {
    //     try writeTemplatedFile(allocator, templated_file, output_dir_path);
    // }
}

fn parseDayFromArgs() !u32 {
    var args = std.process.args();
    _ = args.skip();
    const day_arg = args.next();
    if (day_arg == null) {
        std.debug.print("Please provide a day number\n", .{});
        return error.MissingArgument;
    }

    const day = try std.fmt.parseInt(u32, day_arg.?, 10);

    return day;
}

fn writeTemplatedFile(allocator: std.mem.Allocator, templated_file: TemplatedFile, output_dir_path: []const u8) !void {
    const output_path = try std.fmt.allocPrint(
        allocator,
        "{s}/{s}",
        .{ output_dir_path, templated_file.output_name },
    );
    defer allocator.free(output_path);

    const template_content = try readTemplateFile(
        allocator,
        templated_file.template_name,
    );
    defer allocator.free(template_content);

    const context = switch (templated_file.index) {
        main_template.index => Context{ .answer = null },
        parse_template.index => Context{ .answer = null },
        part_1_template.index => Context{ .answer = 42 },
        part_2_template.index => Context{ .answer = 43 },
        else => unreachable,
    };

    const content = try mustache.allocRenderText(
        allocator,
        template_content,
        context,
    );
    defer allocator.free(content);

    const cwd = std.fs.cwd();
    var file = try cwd.createFile(output_path, .{});
    defer file.close();
    try file.writeAll(content);

    std.debug.print("Generated source file at {s}\n", .{output_path});
}

fn readTemplateFile(allocator: std.mem.Allocator, template_filename: []const u8) ![]const u8 {
    const template_dir = "templates";
    const template_path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ template_dir, template_filename });
    defer allocator.free(template_path);

    const file = std.fs.cwd().openFile(template_path, .{}) catch |err| {
        if (err == error.FileNotFound) {
            std.debug.print("Template file not found: {s}\n", .{template_path});
        }
        return err;
    };
    defer file.close();

    return try file.readToEndAlloc(allocator, std.math.maxInt(usize));
}
