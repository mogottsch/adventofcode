const std = @import("std");
const http = @import("std").http;
const testing = @import("std").testing;
const Client = http.Client;

const warn = std.log.warn;

pub const DayStage = enum {
    New,
    Part1Solved,
    Part2Solved,
};

pub const DayData = struct {
    input: []const u8,
    part_1_example_input: []const u8,
    part_2_example_input: ?[]const u8,
    part_1_example_answer: i32,
    part_2_example_answer: ?i32,
    part_1_real_answer: ?i32,
    part_2_real_answer: ?i32,
    day_stage: DayStage,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *const DayData) void {
        self.allocator.free(self.input);
        self.allocator.free(self.part_1_example_input);
        if (self.part_2_example_input != null) {
            self.allocator.free(self.part_2_example_input.?);
        }
    }
};

const ScrapedData = struct {
    example_1_code_block: []const u8,
    example_2_code_block: ?[]const u8,
    example_1_solution: i32,
    example_2_solution: ?i32,
    real_solution_1: ?i32,
    real_solution_2: ?i32,
    day_stage: DayStage,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *const ScrapedData) void {
        self.allocator.free(self.example_1_code_block);
        if (self.example_2_code_block != null) {
            self.allocator.free(self.example_2_code_block);
        }
    }
};

const Pages = enum {
    Main,
    Input,

    pub fn getPagePath(self: Pages) []const u8 {
        return switch (self) {
            Pages.Main => "",
            Pages.Input => "/input",
        };
    }
};

const AocUrl = struct {
    uri: std.Uri,
    url_string: []const u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, year: u32, day: u32, page: Pages) !AocUrl {
        const path = page.getPagePath();
        const url = try std.fmt.allocPrint(
            allocator,
            "https://adventofcode.com/{d}/day/{d}{s}",
            .{ year, day, path },
        );
        return .{
            .uri = try std.Uri.parse(url),
            .url_string = url,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *const AocUrl) void {
        self.allocator.free(self.url_string);
    }
};

pub fn fetchDayData(allocator: std.mem.Allocator, year: u32, day: u32) !DayData {
    const input = try getInput(allocator, year, day);
    errdefer allocator.free(input);

    const scraped_data = try scrapeMainPage(allocator, year, day);
    errdefer scraped_data.deinit();

    return DayData{
        .input = input,
        .part_1_example_input = scraped_data.example_1_code_block,
        .part_2_example_input = scraped_data.example_2_code_block,
        .part_1_example_answer = scraped_data.example_1_solution,
        .part_2_example_answer = scraped_data.example_2_solution,
        .part_1_real_answer = 0, // TODO: get real answer
        .part_2_real_answer = 0,
        .day_stage = scraped_data.day_stage,
        .allocator = allocator,
    };
}

fn scrapeMainPage(allocator: std.mem.Allocator, year: u32, day: u32) !ScrapedData {
    const body = try fetchMainPageBody(allocator, year, day);
    defer allocator.free(body);

    const day_stage = try detectDayStage(body);
    const code_blocks = try extractCodeBlocks(allocator, body, day_stage);
    const solutions = try extractExampleSolutions(allocator, body, day_stage);

    return ScrapedData{
        .example_1_code_block = code_blocks.example_1,
        .example_2_code_block = code_blocks.example_2,
        .example_1_solution = solutions.solution_1,
        .example_2_solution = solutions.solution_2,
        .real_solution_1 = null,
        .real_solution_2 = null,
        .day_stage = day_stage,
        .allocator = allocator,
    };
}

fn fetchMainPageBody(allocator: std.mem.Allocator, year: u32, day: u32) ![]const u8 {
    // TODO: refactor this to reuse the request logic
    var client = Client{ .allocator = allocator };
    defer client.deinit();

    const url = try AocUrl.init(allocator, year, day, Pages.Main);
    defer url.deinit();

    var response_data_array = std.ArrayList(u8).init(allocator);
    defer response_data_array.deinit();

    const fetch_options = Client.FetchOptions{
        .location = Client.FetchOptions.Location{ .uri = url.uri },
        .method = http.Method.GET,
        .response_storage = Client.FetchOptions.ResponseStorage{ .dynamic = &response_data_array },
    };
    const res = try client.fetch(fetch_options);

    if (res.status != http.Status.ok) {
        warn("Failed to fetch url {s}: {d}", .{ url.url_string, res.status });
        return error.FetchFailed;
    }

    return response_data_array.toOwnedSlice();
}

fn detectDayStage(text: []const u8) !DayStage {
    var count: u32 = 0;
    var last_idx: usize = 0;

    while (true) {
        const idx = std.mem.indexOfPos(u8, text, last_idx, "Your puzzle answer was");
        if (idx == null) {
            break;
        }
        last_idx = idx.? + 1;
        count += 1;
    }

    return switch (count) {
        0 => DayStage.New,
        1 => DayStage.Part1Solved,
        2 => DayStage.Part2Solved,
        else => error.InvalidDayStage,
    };
}

fn extractCodeBlocks(
    allocator: std.mem.Allocator,
    body: []const u8,
    day_stage: DayStage,
) !struct { example_1: []const u8, example_2: ?[]const u8 } {
    var code_blocks = try extractBetween(allocator, body, "<pre><code>", "</code></pre>");
    defer code_blocks.deinit();

    if (day_stage == DayStage.New and code_blocks.strings.len != 1) {
        warn("Expected 1 code block for a new day, got {d}", .{code_blocks.strings.len});
        return error.InvalidCodeBlockCount;
    }
    if (day_stage != DayStage.New and code_blocks.strings.len != 2) {
        warn("Expected 2 code blocks for a part 1 or part 2 solved day, got {d}", .{code_blocks.strings.len});
        return error.InvalidCodeBlockCount;
    }

    const example_1 = try allocator.dupe(u8, code_blocks.strings[0]);
    const example_2 = if (code_blocks.strings.len == 2) try allocator.dupe(u8, code_blocks.strings[1]) else null;

    return .{ .example_1 = example_1, .example_2 = example_2 };
}

fn extractExampleSolutions(
    allocator: std.mem.Allocator,
    body: []const u8,
    day_stage: DayStage,
) !struct { solution_1: i32, solution_2: ?i32 } {
    var example_solution_1: i32 = 0;
    var example_solution_2: ?i32 = null;

    switch (day_stage) {
        .New => {
            const examples = try extractBetween(allocator, body, "<code><em>", "</em></code>");
            defer examples.deinit();

            if (examples.strings.len == 0) return error.NoExampleSolutions;
            example_solution_1 = try std.fmt.parseInt(i32, examples.strings[examples.strings.len - 1], 10);
        },
        .Part1Solved => {
            var parts_iter = std.mem.splitSequence(u8, body, "Your puzzle answer was");

            if (parts_iter.next()) |first_part| {
                const first_examples = try extractBetween(allocator, first_part, "<code><em>", "</em></code>");
                defer first_examples.deinit();

                if (first_examples.strings.len == 0) return error.NoExampleSolutions;
                example_solution_1 = try std.fmt.parseInt(
                    i32,
                    first_examples.strings[first_examples.strings.len - 1],
                    10,
                );
            }

            if (parts_iter.next()) |second_part| {
                const second_examples = try extractBetween(allocator, second_part, "<code><em>", "</em></code>");
                defer second_examples.deinit();

                if (second_examples.strings.len > 0) return error.NoExampleSolutions;
                example_solution_2 = try std.fmt.parseInt(
                    i32,
                    second_examples.strings[second_examples.strings.len - 1],
                    10,
                );
            }
        },
        .Part2Solved => return error.Unimplemented,
    }

    return .{ .solution_1 = example_solution_1, .solution_2 = example_solution_2 };
}

const ExtractedStrings = struct {
    strings: [][]const u8,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *const ExtractedStrings) void {
        for (self.strings) |str| {
            self.allocator.free(str);
        }
        self.allocator.free(self.strings);
    }
};

fn extractBetween(
    allocator: std.mem.Allocator,
    text: []const u8,
    start: []const u8,
    end: []const u8,
) !ExtractedStrings {
    var results = std.ArrayList([]const u8).init(allocator);

    var rest = text;
    while (std.mem.indexOf(u8, rest, start)) |start_idx| {
        const content_start = start_idx + start.len;
        if (std.mem.indexOf(u8, rest[content_start..], end)) |end_idx| {
            const code = rest[content_start .. content_start + end_idx];
            try results.append(try allocator.dupe(u8, code));
            rest = rest[content_start + end_idx + end.len ..];
        }
    }

    return ExtractedStrings{
        .strings = try results.toOwnedSlice(),
        .allocator = allocator,
    };
}

fn getInput(allocator: std.mem.Allocator, year: u32, day: u32) ![]const u8 {
    var client = Client{ .allocator = allocator };
    defer client.deinit();

    const url = try AocUrl.init(allocator, year, day, Pages.Input);
    defer url.deinit();

    // TODO: refactor this to reuse the request logic
    var response_data_array = std.ArrayList(u8).init(allocator);
    defer response_data_array.deinit();

    const cookie_header = try buildCookieHeader(allocator);
    defer allocator.free(cookie_header.value);

    const fetch_options = Client.FetchOptions{
        .location = Client.FetchOptions.Location{ .uri = url.uri },
        .method = http.Method.GET,
        .response_storage = Client.FetchOptions.ResponseStorage{ .dynamic = &response_data_array },
        .extra_headers = &[_]http.Header{cookie_header},
    };
    const res = try client.fetch(fetch_options);

    if (res.status != http.Status.ok) {
        warn("Failed to fetch input for day {d} for year {d} via {s}: {d}", .{ day, year, url.url_string, res.status });
        const response_data = try response_data_array.toOwnedSlice();
        defer allocator.free(response_data);
        warn("Response: {s}", .{response_data});
        return error.FetchFailed;
    }

    return try response_data_array.toOwnedSlice();
}

fn buildCookieHeader(allocator: std.mem.Allocator) !http.Header {
    const session_cookie = try readCookieFromEnv(allocator);
    defer allocator.free(session_cookie);
    const cookie = try std.fmt.allocPrint(allocator, "session={s}", .{session_cookie});

    return http.Header{
        .name = "Cookie",
        .value = cookie,
    };
}

fn readCookieFromEnv(allocator: std.mem.Allocator) ![]const u8 {
    var env_map = try std.process.getEnvMap(allocator);
    defer env_map.deinit();

    const cookie = env_map.get("AOC_COOKIE");
    if (cookie == null) {
        warn("AOC_COOKIE environment variable not set", .{});
        return error.MissingCookie;
    }

    return try allocator.dupe(u8, cookie.?);
}

test "detectDayStage" {
    try testing.expectEqual(DayStage.New, try detectDayStage("Some text without any answers"));
    try testing.expectEqual(DayStage.Part1Solved, try detectDayStage("Some text Your puzzle answer was 42"));
    try testing.expectEqual(DayStage.Part2Solved, try detectDayStage("Your puzzle answer was 42. Later: Your puzzle answer was 123"));
    try testing.expectError(error.InvalidDayStage, detectDayStage("Your puzzle answer was 1 Your puzzle answer was 2 Your puzzle answer was 3"));
}
