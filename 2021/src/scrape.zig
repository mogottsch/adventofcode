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
    allocator: std.mem.Allocator,

    pub fn deinit(self: *const DayData) void {
        self.allocator.free(self.input);
        self.allocator.free(self.part_1_example_input);
        self.allocator.free(self.part_2_example_input);
    }
};

const CodeBlocks = struct {
    blocks: [][]const u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, raw_blocks: []const []const u8) !CodeBlocks {
        var blocks = try allocator.alloc([]u8, raw_blocks.len);
        for (raw_blocks, 0..) |block, i| {
            blocks[i] = try allocator.dupe(u8, block);
        }
        return .{
            .blocks = blocks,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *const CodeBlocks) void {
        for (self.blocks) |block| {
            self.allocator.free(block);
        }
        self.allocator.free(self.blocks);
    }

    pub fn getBlock(self: CodeBlocks, index: usize) []const u8 {
        return if (index < self.blocks.len) self.blocks[index] else self.blocks[0];
    }
};

const Pages = enum {
    Main,
    Input,

    pub fn getPagePath(self: Pages) []const u8 {
        return switch (self) {
            Pages.Main => "/",
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
    var client = Client{ .allocator = allocator };
    defer client.deinit();

    const input = try getInput(allocator, &client, year, day);
    defer allocator.free(input);

    const code_blocks = try getCodeBlocks(allocator, &client, year, day);
    defer code_blocks.deinit();

    const part_1_example_input = code_blocks.getBlock(0);
    const part_2_example_input = code_blocks.getBlock(1);

    return DayData{
        .input = try allocator.dupe(u8, input),
        .part_1_example_input = try allocator.dupe(u8, part_1_example_input),
        .part_2_example_input = try allocator.dupe(u8, part_2_example_input),
        .part_1_example_answer = 0,
        .part_2_example_answer = 0,
        .allocator = allocator,
    };
}

fn getCodeBlocks(allocator: std.mem.Allocator, client: *Client, year: u32, day: u32) !CodeBlocks {
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
        warn("Failed to fetch day {d} for year {d}: {d}", .{ day, year, res.status });
        return error.FetchFailed;
    }

    const body = try response_data_array.toOwnedSlice();
    defer allocator.free(body);

    var code_blocks_list = try extractCodeBlocks(allocator, body);
    defer code_blocks_list.deinit();
    const code_blocks = try code_blocks_list.toOwnedSlice();
    defer allocator.free(code_blocks);

    if (code_blocks.len != 1 and code_blocks.len != 2) {
        warn("Expected 1 or 2 code blocks, found {d}", .{code_blocks.len});
        return error.InvalidCodeBlockCount;
    }

    return CodeBlocks.init(allocator, code_blocks);
}

fn extractCodeBlocks(allocator: std.mem.Allocator, text: []const u8) !std.ArrayList([]const u8) {
    var results = std.ArrayList([]const u8).init(allocator);

    const start_tag = "<pre><code>";
    const end_tag = "</code></pre>";

    var rest = text;
    while (std.mem.indexOf(u8, rest, start_tag)) |start_idx| {
        const content_start = start_idx + start_tag.len;
        if (std.mem.indexOf(u8, rest[content_start..], end_tag)) |end_idx| {
            const code = rest[content_start .. content_start + end_idx];
            try results.append(code);
            rest = rest[content_start + end_idx + end_tag.len ..];
        }
    }

    return results;
}

fn getInput(allocator: std.mem.Allocator, client: *Client, year: u32, day: u32) ![]const u8 {
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
