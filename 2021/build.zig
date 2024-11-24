const std = @import("std");
const warn = std.log.warn;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var dir = std.fs.cwd().openDir("src", .{ .iterate = true }) catch |err| {
        std.debug.print("Error opening src directory: {}\n", .{err});
        return;
    };
    defer dir.close();

    var dir_iterator = dir.iterate();
    while (dir_iterator.next() catch |err| {
        std.debug.print("Error iterating directory: {}\n", .{err});
        return;
    }) |entry| {
        if (entry.kind != .directory) continue;
        const day_num = std.fmt.parseInt(u8, entry.name, 10) catch continue;
        const main_path = b.fmt("src/{:0>2}/main.zig", .{day_num});

        std.fs.cwd().access(main_path, .{}) catch |err| {
            warn("Could not find main.zig for day {d}: {}", .{ day_num, err });
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
        const run_step = b.step(b.fmt("run-{d}", .{day_num}), b.fmt("Run day {d} solution", .{day_num}));
        run_step.dependOn(&run_cmd.step);

        const test_step = b.step(b.fmt("test-{d}", .{day_num}), b.fmt("Run tests for day {d}", .{day_num}));

        inline for ([_][]const u8{ "part_1.zig", "part_2.zig", "parse.zig" }) |test_file| {
            const test_path = b.fmt("src/{:0>2}/{s}", .{ day_num, test_file });
            var file_exists = true;
            std.fs.cwd().access(test_path, .{}) catch {
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

        const main_test_step = b.step("test", "Run all tests");
        main_test_step.dependOn(test_step);
    }
}
