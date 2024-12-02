const std = @import("std");
const path = @import("common").path;
const log = std.log;

pub const Report = struct {
    readings: []u32,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Report) void {
        self.allocator.free(self.readings);
    }

    pub fn fromLine(allocator: std.mem.Allocator, line: []const u8) !Report {
        var iterator = std.mem.splitScalar(u8, line, ' ');
        var list = std.ArrayList(u32).init(allocator);

        while (iterator.next()) |entry| {
            const number = try std.fmt.parseInt(u32, entry, 10);
            try list.append(number);
        }

        const readings = try list.toOwnedSlice();
        return Report{
            .allocator = allocator,
            .readings = readings,
        };
    }
};

pub const Input = struct {
    reports: []Report,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Input) void {
        for (self.reports) |*report| {
            report.deinit();
        }
        self.allocator.free(self.reports);
    }
};

pub fn parse_file(allocator: std.mem.Allocator, filename: []const u8) !Input {
    const filepath = try path.buildPath(allocator, filename);
    defer allocator.free(filepath);
    const file = try std.fs.openFileAbsolute(filepath, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(content);

    var count: usize = 0;
    for (content) |c| {
        if (c == '\n') count += 1;
    }

    var reports = std.ArrayList(Report).init(allocator);
    errdefer reports.deinit();

    var line_iterator = std.mem.splitScalar(u8, content[0 .. content.len - 1], '\n');
    var i: usize = 0;
    while (line_iterator.next()) |line| : (i += 1) {
        const report = try Report.fromLine(allocator, line);
        try reports.append(report);
    }

    const reportArray = try reports.toOwnedSlice();

    return Input{ .reports = reportArray, .allocator = allocator };
}
