const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    var current_numbers = std.ArrayList(u64).init(allocator);
    for (input.numbers.items) |number| {
        try current_numbers.append(number);
    }

    for (0..25) |_| {
        const new_numbers = try doBlink(allocator, current_numbers.items);
        current_numbers.deinit();
        current_numbers = new_numbers;
    }
    defer current_numbers.deinit();
    return current_numbers.items.len;
}

fn doBlink(allocator: std.mem.Allocator, numbers: []u64) !std.ArrayList(u64) {
    var new_numbers = std.ArrayList(u64).init(allocator);

    for (numbers) |number| {
        try processNumber(number, &new_numbers);
    }
    // std.debug.print("new_numbers: {d}\n", .{new_numbers.items});
    return new_numbers;
}

fn processNumber(
    number: u64,
    new_numbers: *std.ArrayList(u64),
) !void {
    if (number == 0) {
        try new_numbers.append(1);
        return;
    }
    const n_digits = countDigits(number);
    if (isEven(n_digits)) {
        const split_numbers = splitNumber(number, n_digits);
        try new_numbers.append(split_numbers.first);
        try new_numbers.append(split_numbers.second);
        return;
    }
    try new_numbers.append(number * 2024);
}

fn isEven(n: u64) bool {
    return n % 2 == 0;
}

fn countDigits(n: u64) usize {
    var count: usize = 1;
    var num = n;
    while (num >= 10) : (num /= 10) {
        count += 1;
    }
    return count;
}

fn splitNumber(n: u64, n_digits: u64) struct { first: u64, second: u64 } {
    const half_digits = n_digits / 2;
    const divisor = std.math.pow(u64, 10, half_digits);

    return .{
        .first = n / divisor,
        .second = n % divisor,
    };
}

fn sumNumbers(numbers: []u64) u64 {
    var sum: u64 = 0;
    for (numbers) |number| {
        sum += number;
    }
    return sum;
}
