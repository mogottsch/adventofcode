const std = @import("std");
const mustache = @import("mustache");
const scrape = @import("scrape.zig");
const config = @import("config");
const pretty = @import("pretty");
const cwd = std.fs.cwd();

const log = std.log;

const TemplatedFile = struct {
    index: u32,
    template_name: []const u8,
    output_name: []const u8,
    should_overwrite: bool,
};
const parse_template = TemplatedFile{
    .index = 0,
    .template_name = "parse.zig.mustache",
    .output_name = "parse.zig",
    .should_overwrite = false,
};
const main_template = TemplatedFile{
    .index = 1,
    .template_name = "main.zig.mustache",
    .output_name = "main.zig",
    .should_overwrite = true,
};
const part_1_template = TemplatedFile{
    .index = 2,
    .template_name = "part_1.zig.mustache",
    .output_name = "part_1.zig",
    .should_overwrite = false,
};
const part_1_test_template = TemplatedFile{
    .index = 3,
    .template_name = "part_1_test.zig.mustache",
    .output_name = "part_1_test.zig",
    .should_overwrite = true,
};
const part_2_template = TemplatedFile{
    .index = 4,
    .template_name = "part_2.zig.mustache",
    .output_name = "part_2.zig",
    .should_overwrite = false,
};
const part_2_test_template = TemplatedFile{
    .index = 5,
    .template_name = "part_2_test.zig.mustache",
    .output_name = "part_2_test.zig",
    .should_overwrite = true,
};
const bench_template = TemplatedFile{
    .index = 6,
    .template_name = "bench.zig.mustache",
    .output_name = "bench.zig",
    .should_overwrite = true,
};
const templated_files = [_]TemplatedFile{
    main_template,
    parse_template,
    part_1_template,
    part_1_test_template,
    part_2_template,
    part_2_test_template,
    bench_template,
};

// TODO: somehow split this up into multiple structs
const Context = struct {
    part_2: bool,

    example_answer: ?u64,
    real_answer: ?u64,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const day = try parseDayFromArgs();
    log.info("Generating day {d}", .{day});

    const day_data = try scrape.fetchDayData(allocator, config.YEAR, day);
    defer day_data.deinit();

    // try pretty.print(allocator, day_data, .{});

    const output_dir_path = try std.fmt.allocPrint(allocator, "src/{:0>2}", .{day});
    defer allocator.free(output_dir_path);

    cwd.makeDir(output_dir_path) catch |err| {
        if (err != error.PathAlreadyExists) return err;
    };

    for (templated_files) |templated_file| {
        if (day_data.day_stage == scrape.DayStage.New and
            (templated_file.index == part_2_template.index or templated_file.index == part_2_test_template.index))
        {
            continue;
        }
        try writeTemplatedFile(allocator, templated_file, output_dir_path, day_data);
    }

    try writeDataDir(allocator, output_dir_path, day_data);
}

fn parseDayFromArgs() !u32 {
    var args = std.process.args();
    _ = args.skip();
    const day_arg = args.next();
    if (day_arg == null) {
        log.err("Please provide a day number", .{});
        return error.MissingArgument;
    }

    const day = try std.fmt.parseInt(u32, day_arg.?, 10);

    return day;
}

fn writeTemplatedFile(
    allocator: std.mem.Allocator,
    templated_file: TemplatedFile,
    output_dir_path: []const u8,
    day_data: scrape.DayData,
) !void {
    const output_path = try std.fmt.allocPrint(
        allocator,
        "{s}/{s}",
        .{ output_dir_path, templated_file.output_name },
    );
    defer allocator.free(output_path);

    if (try checkFileExists(output_path)) {
        if (!templated_file.should_overwrite) {
            log.info("File already exists at {s}, skipping", .{output_path});
            return;
        }

        log.info("Overwriting file at {s}", .{output_path});
        try cwd.deleteFile(output_path);
    }

    const template_content = try readTemplateFile(
        allocator,
        templated_file.template_name,
    );
    defer allocator.free(template_content);

    const part_2_available = day_data.day_stage != scrape.DayStage.New;

    const context = switch (templated_file.index) {
        main_template.index => Context{
            .real_answer = null,
            .example_answer = null,
            .part_2 = part_2_available,
        },
        parse_template.index => Context{
            .real_answer = null,
            .example_answer = null,
            .part_2 = part_2_available,
        },
        part_1_template.index => Context{
            .real_answer = day_data.part_1_real_answer,
            .example_answer = day_data.part_1_example_answer,
            .part_2 = part_2_available,
        },
        part_2_template.index => Context{
            .real_answer = day_data.part_2_real_answer,
            .example_answer = day_data.part_2_example_answer,
            .part_2 = part_2_available,
        },
        bench_template.index => Context{
            .real_answer = null,
            .example_answer = null,
            .part_2 = part_2_available,
        },
        part_1_test_template.index => Context{
            .real_answer = day_data.part_1_real_answer,
            .example_answer = day_data.part_1_example_answer,
            .part_2 = part_2_available,
        },
        part_2_test_template.index => Context{
            .real_answer = day_data.part_2_real_answer,
            .example_answer = day_data.part_2_example_answer,
            .part_2 = part_2_available,
        },
        else => unreachable,
    };

    const content = try mustache.allocRenderText(
        allocator,
        template_content,
        context,
    );
    defer allocator.free(content);

    var file = try cwd.createFile(output_path, .{});
    defer file.close();
    try file.writeAll(content);

    log.info("Generated source file at {s}", .{output_path});
}

fn writeDataDir(allocator: std.mem.Allocator, output_dir_path: []const u8, day_data: scrape.DayData) !void {
    const data_dir_path = try std.fmt.allocPrint(allocator, "{s}/data", .{output_dir_path});
    defer allocator.free(data_dir_path);

    cwd.makeDir(data_dir_path) catch |err| {
        if (err != error.PathAlreadyExists) return err;
    };

    const example_1_path = try std.fmt.allocPrint(allocator, "{s}/example_1.txt", .{data_dir_path});
    defer allocator.free(example_1_path);
    const example_2_path = try std.fmt.allocPrint(allocator, "{s}/example_2.txt", .{data_dir_path});
    defer allocator.free(example_2_path);
    const input_path = try std.fmt.allocPrint(allocator, "{s}/input.txt", .{data_dir_path});
    defer allocator.free(input_path);

    if (!try checkFileExists(example_1_path)) {
        var example_1_file = try cwd.createFile(example_1_path, .{});
        defer example_1_file.close();
        std.debug.assert(day_data.part_1_example_input.len > 0);
        try example_1_file.writeAll(day_data.part_1_example_input);
        log.info("Generated example 1 file at {s}", .{example_1_path});
    }

    if (!try checkFileExists(example_2_path) and day_data.part_2_example_input != null) {
        var example_2_file = try cwd.createFile(example_2_path, .{});
        defer example_2_file.close();
        std.debug.assert(day_data.part_2_example_input.?.len > 0);
        try example_2_file.writeAll(day_data.part_2_example_input.?);
        log.info("Generated example 2 file at {s}", .{example_2_path});
    }

    if (!try checkFileExists(input_path)) {
        var input_file = try cwd.createFile(input_path, .{});
        defer input_file.close();
        std.debug.assert(day_data.input.len > 0);
        try input_file.writeAll(day_data.input);
        log.info("Generated input file at {s}", .{input_path});
    }
}

fn readTemplateFile(allocator: std.mem.Allocator, template_filename: []const u8) ![]const u8 {
    const template_dir = "templates";
    const template_path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ template_dir, template_filename });
    defer allocator.free(template_path);

    const file = std.fs.cwd().openFile(template_path, .{}) catch |err| {
        if (err == error.FileNotFound) {
            log.warn("Template file not found: {s}", .{template_path});
        }
        return err;
    };
    defer file.close();

    return try file.readToEndAlloc(allocator, std.math.maxInt(usize));
}

fn checkFileExists(output_path: []const u8) !bool {
    if (cwd.access(output_path, .{})) |_| {
        return true;
    } else |err| {
        if (err == error.FileNotFound) {
            return false;
        }
        return err;
    }
}
