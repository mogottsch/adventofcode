const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const common = @import("common");

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    var current_numbers = std.AutoHashMap(u64, u64).init(allocator);
    for (input.numbers.items) |number| {
        try putOrIncrementBy(&current_numbers, number, 1);
    }
    const result = try doBlinkNTimes(allocator, current_numbers, 25);
    return result;
}

pub fn doBlinkNTimes(allocator: std.mem.Allocator, numbers: std.AutoHashMap(u64, u64), n: u64) !u64 {
    var current_numbers = numbers;
    for (0..n) |_| {
        const new_numbers = try doBlink(allocator, current_numbers);
        current_numbers.deinit();
        current_numbers = new_numbers;
    }
    defer current_numbers.deinit();
    return sumNumbers(current_numbers);
}

fn doBlink(allocator: std.mem.Allocator, numbers: std.AutoHashMap(u64, u64)) !std.AutoHashMap(u64, u64) {
    var new_numbers = std.AutoHashMap(u64, u64).init(allocator);

    var iter = numbers.iterator();
    while (iter.next()) |entry| {
        // for (0..entry.value_ptr.*) |_| {
        //     try processNumber(entry.key_ptr.*, &new_numbers);
        // }
        try processNumberNTimes(entry.key_ptr.*, &new_numbers, entry.value_ptr.*);
    }
    return new_numbers;
}

fn processNumberNTimes(
    number: u64,
    new_numbers: *std.AutoHashMap(u64, u64),
    n: u64,
) !void {
    if (number == 0) {
        try putOrIncrementBy(new_numbers, 1, n);
        return;
    }
    const n_digits = countDigits(number);
    if (isEven(n_digits)) {
        const split_numbers = splitNumber(number, n_digits);
        try putOrIncrementBy(new_numbers, split_numbers.first, n);
        try putOrIncrementBy(new_numbers, split_numbers.second, n);
        return;
    }
    try putOrIncrementBy(new_numbers, number * 2024, n);
}

pub fn putOrIncrementBy(
    numbers: *std.AutoHashMap(u64, u64),
    number: u64,
    increment: u64,
) !void {
    const gop = try numbers.getOrPut(number);
    if (gop.found_existing) {
        gop.value_ptr.* += increment;
        return;
    }
    gop.value_ptr.* = increment;
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

fn sumNumbers(numbers: std.AutoHashMap(u64, u64)) u64 {
    var sum: u64 = 0;
    var value_iter = numbers.valueIterator();
    while (value_iter.next()) |count| {
        sum += count.*;
    }
    return sum;
}
