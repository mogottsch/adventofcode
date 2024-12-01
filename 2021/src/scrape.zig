const std = @import("std");
const http = @import("std").http;
// const rem = @import("rem");
const Client = http.Client;

const warn = std.log.warn;

const DayData = struct {
    input: []const u8,
    part_1_example_input: []const u8,
    part_2_example_input: []const u8,
    part_1_example_answer: i32,
    part_2_example_answer: i32,
    part_1_real_answer: i32,
    part_2_real_answer: i32,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *const DayData) void {
        self.allocator.free(self.input);
        self.allocator.free(self.part_1_example_input);
        self.allocator.free(self.part_2_example_input);
    }
};

const ScrapedData = struct {
    example_code_blocks: [][]const u8,
    example_solutions: []const i32,

    real_solutions: []const i32,

    allocator: std.mem.Allocator,

    pub fn init(
        allocator: std.mem.Allocator,
        raw_example_code_blocks: []const []const u8,
        raw_example_solutions: []const i32,
        // raw_real_solutions: []const i32,
    ) !ScrapedData {
        std.debug.assert(raw_example_code_blocks.len == 1 or raw_example_code_blocks.len == 2);
        std.debug.assert(raw_example_solutions.len == 1 or raw_example_solutions.len == 2);

        var example_code_blocks = try allocator.alloc([]u8, raw_example_code_blocks.len);
        for (raw_example_code_blocks, 0..) |block, i| {
            example_code_blocks[i] = try allocator.dupe(u8, block);
        }

        const raw_real_solutions = try allocator.alloc(i32, 2);

        return .{
            .example_code_blocks = example_code_blocks,
            .example_solutions = try allocator.dupe(i32, raw_example_solutions),
            .real_solutions = raw_real_solutions,

            .allocator = allocator,
        };
    }

    pub fn deinit(self: *const ScrapedData) void {
        for (self.example_code_blocks) |block| {
            self.allocator.free(block);
        }
        self.allocator.free(self.example_code_blocks);
        self.allocator.free(self.example_solutions);
        self.allocator.free(self.real_solutions);
    }

    pub fn getExampleCodeBlock(self: ScrapedData, index: usize) []const u8 {
        return if (index < self.example_code_blocks.len) self.example_code_blocks[index] else self.example_code_blocks[0];
    }

    pub fn getExampleSolution(self: ScrapedData, index: usize) i32 {
        return if (index < self.example_solutions.len) self.example_solutions[index] else self.example_solutions[0];
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

pub fn scrapeDay(allocator: std.mem.Allocator, year: u32, day: u32) !DayData {
    const input = try getInput(allocator, year, day);
    defer allocator.free(input);

    const scraped_data = try scrapeData(allocator, year, day);
    defer scraped_data.deinit();

    // TODO: move this to init and add deinit
    const part_1_example_input = try allocator.dupe(u8, scraped_data.getExampleCodeBlock(0));
    const part_2_example_input = try allocator.dupe(u8, scraped_data.getExampleCodeBlock(1));
    const part_1_example_answer = scraped_data.getExampleSolution(0);
    const part_2_example_answer = scraped_data.getExampleSolution(1);

    return DayData{
        .input = try allocator.dupe(u8, input),
        .part_1_example_input = part_1_example_input,
        .part_2_example_input = part_2_example_input,
        .part_1_example_answer = part_1_example_answer,
        .part_2_example_answer = part_2_example_answer,
        .part_1_real_answer = 0, // TODO: get real answer
        .part_2_real_answer = 0,
        .allocator = allocator,
    };
}

fn scrapeData(allocator: std.mem.Allocator, year: u32, day: u32) !ScrapedData {
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

    const body = try response_data_array.toOwnedSlice();
    defer allocator.free(body);

    var code_blocks_list = try extractBetween(allocator, body, "<pre><code>", "</code></pre>");
    defer code_blocks_list.deinit();
    const code_blocks = try code_blocks_list.toOwnedSlice();
    defer allocator.free(code_blocks);

    if (code_blocks.len != 1 and code_blocks.len != 2) {
        warn("Expected 1 or 2 code blocks, found {d}", .{code_blocks.len});
        return error.InvalidCodeBlockCount;
    }

    var example_solutions_list = try extractBetween(allocator, body, "<code><em>", "</em></code>");
    defer example_solutions_list.deinit();
    const example_solutions = try example_solutions_list.toOwnedSlice();
    defer allocator.free(example_solutions);

    var example_solutions_ints = try allocator.alloc(i32, example_solutions.len);
    defer allocator.free(example_solutions_ints);
    for (example_solutions, 0..) |solution, i| {
        example_solutions_ints[i] = try std.fmt.parseInt(i32, solution, 10);
    }

    return ScrapedData.init(allocator, code_blocks, example_solutions_ints);
}

fn extractBetween(
    allocator: std.mem.Allocator,
    text: []const u8,
    start: []const u8,
    end: []const u8,
) !std.ArrayList([]const u8) {
    var results = std.ArrayList([]const u8).init(allocator);

    var rest = text;
    while (std.mem.indexOf(u8, rest, start)) |start_idx| {
        const content_start = start_idx + start.len;
        if (std.mem.indexOf(u8, rest[content_start..], end)) |end_idx| {
            const code = rest[content_start .. content_start + end_idx];
            try results.append(code);
            rest = rest[content_start + end_idx + end.len ..];
        }
    }

    return results;
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
