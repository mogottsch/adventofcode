const std = @import("std");
const warn = std.log.warn;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    addGenerateStep(b, target, optimize);

    const cwd = std.fs.cwd();

    var dir = cwd.openDir("src", .{ .iterate = true }) catch |err| {
        warn("Error opening src directory: {any}", .{err});
        return;
    };
    defer dir.close();

    var dir_iterator = dir.iterate();
    while (dir_iterator.next() catch |err| {
        warn("Error iterating directory: {any}", .{err});
        return;
    }) |entry| {
        if (entry.kind != .directory) continue;
        const day_num = std.fmt.parseInt(u8, entry.name, 10) catch continue;
        const main_path = b.fmt("src/{:0>2}/main.zig", .{day_num});

        cwd.access(main_path, .{}) catch |err| {
            warn("Could not find main.zig for day {d}: {any}", .{ day_num, err });
            warn("Checked path: {s}", .{main_path});
            continue;
        };

        const options = b.addOptions();
        options.addOption(u8, "DAY", day_num);

        const commonModule = b.addModule("common", .{
            .root_source_file = b.path("src/common/common.zig"),
        });
        commonModule.addOptions("config", options);

        const exe = b.addExecutable(.{
            .name = b.fmt("{:0>2}", .{day_num}),
            .root_source_file = b.path(main_path),
            .target = target,
            .optimize = optimize,
        });
        exe.root_module.addImport("common", commonModule);
        exe.root_module.addOptions("config", options);
        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step(
            b.fmt("run-{d}", .{day_num}),
            b.fmt("Run day {d} solution", .{day_num}),
        );
        run_step.dependOn(&run_cmd.step);

        const test_step = b.step(
            b.fmt("test-{d}", .{day_num}),
            b.fmt("Run tests for day {d}", .{day_num}),
        );

        inline for ([_][]const u8{ "part_1.zig", "part_2.zig", "parse.zig" }) |test_file| {
            addTestIfExists(
                b,
                day_num,
                test_file,
                target,
                optimize,
                commonModule,
                options,
                test_step,
            );
        }
    }
}

fn addTestIfExists(
    b: *std.Build,
    day_num: u8,
    test_file: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    commonModule: *std.Build.Module,
    options: *std.Build.Step.Options,
    test_step: *std.Build.Step,
) void {
    const test_path = b.fmt("src/{:0>2}/{s}", .{ day_num, test_file });
    const cwd = std.fs.cwd();

    var file_exists = true;
    cwd.access(test_path, .{}) catch {
        file_exists = false;
    };

    if (file_exists) {
        const test_exe = b.addTest(.{
            .name = b.fmt("test-day_{d}-{s}", .{ day_num, test_file }),
            .root_source_file = b.path(test_path),
            .target = target,
            .optimize = optimize,
        });
        test_exe.root_module.addImport("common", commonModule);
        test_exe.root_module.addOptions("config", options);

        const run_test = b.addRunArtifact(test_exe);
        test_step.dependOn(&run_test.step);
    } else {
        warn("Could not find test file for day {d}: {s}", .{ day_num, test_file });
    }
}

fn addGenerateStep(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) void {
    const generate_exe = b.addExecutable(.{
        .name = "generate",
        .root_source_file = b.path("src/generate.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(generate_exe);

    const generate_cmd = b.addRunArtifact(generate_exe);

    generate_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        generate_cmd.addArgs(args);
    }

    const generate_step = b.step("generate", "Generate template source files for new day");
    generate_step.dependOn(&generate_cmd.step);
}
